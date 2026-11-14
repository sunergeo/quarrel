# Architecture — shipping at least once to an OTLP collector

- **Lineage:** SOW `../SOW-ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once.md`
  (D1–D11); ADR-0006 (production requirements), ADR-0007 (wire contract), ADR-0011 (I/O-free core),
  ADR-0012 (CI). Labels continue the SOW's sequences: decisions from **D12**, open questions from
  **OQ8**, risks from **R1**.
- **Status:** Draft for SB's review, 2026-11-14.

## 1. What has to be true

One invariant carries the whole outcome: **a file's saved offset never passes the last line the
collector has acknowledged** (ADR-0007 §3). Everything below either serves it or must not break it.
Duplicates after a crash are allowed; loss is not.

## 2. Components

```
crates/quarrel-core      (new, I/O-free; ADR-0011)
  batch      BatchBuilder: adds lines, closes on lines / raw bytes / wait-from-first-line (D10)
  ledger     per-file read cursor vs committed offset; applies acks; never moves past an ack
  otlp       maps lines and gaps to OTLP log records (ADR-0007 §2), encodes protobuf
  response   classifies an HTTP outcome into Ack / Reject / Stop / Split / Retry(after) (ADR-0007 §3–4)
  config     the config model, profiles, precedence (field > profile > default), validation
  fingerprint  the frozen identity of a file (D15)

crates/quarrel-shipper   (I/O around the core)
  reader     thread: polls files, reads complete lines from each file's read cursor, feeds batches
  sender     thread: gzips, POSTs, waits, retries/backs off, reports outcomes
  state      atomic offset store (exists; fixed for Windows, R1)
  quarantine local, bounded store for batches the collector rejected (D14)
  config     loads TOML + environment, hands a validated model to the core
  main       wiring, signals, startup report of effective settings
```

**D12 — `quarrel-core` is created now** with the pieces above, rather than later. ADR-0011 requires
an I/O-free core, the demo consumer (BL-0019) will reuse `otlp` to decode, and every piece of the
invariant becomes testable without a network, a clock or a file system.

## 3. Threads and data flow

```
 files ──► reader thread ──(batch, bounded channel cap 1)──► sender thread ──► collector
              ▲   owns: ledger, state, quarantine                  │
              └──────────────(outcome channel)─────────────────────┘
```

- **The reader** polls every `min(250 ms, max_wait / 2)`, reads only *complete* lines from each
  file's **read cursor**, and adds them to the open batch. It reads at most what the open batch can
  still take, so memory stays inside D9 (the existing `complete_lines_from` reads to end of file and
  must be bounded; R2).
- **One batch in flight.** The channel to the sender holds one batch; when it is full the reader
  stops reading (the source file is the buffer). With one batch being built and one in flight, batch
  memory stays near two batch sizes (≈ 2 MiB for `balanced`).
- **The sender** gzips and POSTs, waits for the answer, applies ADR-0007 §4, and sends the
  **outcome** back. It never touches state.
- **D13 — the reader thread is the only writer of offsets.** It owns the ledger and the state store,
  and applies outcomes in order. With one batch in flight there is exactly one possible order.

## 4. The offset-save path, and what a crash does

On `Ack(batch)` the reader moves each file's committed offset to that batch's last line end, then
saves state atomically (write temp, flush to disk, rename over, flush the directory where the OS
allows it). Kill points:

| Killed… | On restart | Result |
|---|---|---|
| while reading or batching | resumes from the committed offset | lines re-read; nothing lost |
| while the POST is in flight | committed offset unchanged | batch re-sent: duplicates possible, no loss |
| after the 200, before the save | committed offset unchanged | batch re-sent: duplicates, no loss |
| during the save | old or new state file, never torn | at worst the previous row above |
| after the save | resumes after the batch | exact |

The collector drops duplicates by `(host.name, quarrel.file.fingerprint, quarrel.file.offset)`.
Sc4 checks exactly this table with 20 kills.

## 5. Response handling (ADR-0007 §4, made concrete)

| Outcome | Sender | Reader / ledger |
|---|---|---|
| Ack | report Ack | commit, save |
| Reject (`400`, or `200` with rejected records) | write the batch to quarantine, report Rejected | commit past it **only after** the quarantine file is on disk and a `quarrel.gap` (kind `rejected`) is queued (D14) |
| Stop (`401`, `403`) | stop sending; re-try authentication every 60 s | stop batching (backpressure); health: unhealthy, reason |
| Split (`413`) | halve the batch and send each half; a single line that still gets `413` is quarantined as Reject | commit per acknowledged half, in order |
| Retry (`429`, `502`, `503`, `504`, timeout, connection error, other `5xx`) | back off: 1 s doubling to 60 s, ±20 % jitter, honour `Retry-After`; same batch, unchanged | nothing commits; reading pauses once the next batch is full |

**D14 — quarantine counts as a disposition.** A rejected batch is written to a local quarantine
directory, flushed to disk, and reported as a gap; only then may the offset pass it. Quarantine is
bounded (OQ9) and its contents are kept for an operator, never resent automatically.

## 6. Identity on the wire

- **D15 — a file's fingerprint is frozen when first computed.** The sha256 of the first
  min(file length, 1 KiB) bytes, with that length recorded; it does not change as the file grows,
  because those bytes do not change unless the file is truncated or replaced (M3/M4 handle those).
  An empty file is not shipped until it has a complete line. Without freezing, a small growing file
  would change its dedupe key between batches.
- Resource attributes: `service.name = quarrel-shipper`, `service.version` from the build,
  `host.name` from config (else the OS hostname), `deployment.environment.name` from `QUARREL_ENV`,
  plus configured labels (ADR-0007 §2).
- Until M3 (BL-0002), offsets are keyed by path; the fingerprint travels as an attribute.

## 7. Configuration

```toml
[identity]
host = "web-01"                 # optional; defaults to the OS hostname
labels = { site = "dc1" }

[[inputs]]
paths = ["/var/log/app/*.log"]  # explicit files in this SOW; globs arrive with M3

[output]
endpoint = "https://collector.example:4318"
headers = { authorization = { env = "QUARREL_TOKEN" } }   # secrets by reference, never inline
ca_file = "/etc/quarrel/ca.pem"                          # optional extra CA

[output.batch]
profile = "balanced"            # D10; overrides: max_lines, max_bytes, max_wait

[state]
dir = "/var/lib/quarrel"        # offsets and quarantine
```

Every key has an environment form (`QUARREL_OUTPUT_ENDPOINT`, `QUARREL_BATCH_PROFILE`, …; ADR-0006).
At startup the shipper prints the effective settings and where each came from, with secrets shown as
`<redacted>` (D10, Sc8).

## 8. Dependencies (shipper and core)

| Need | Crate | Licence | Why this one |
|---|---|---|---|
| HTTP client, blocking | `ureq` | MIT OR Apache-2.0 | synchronous (ADR-0011), small |
| TLS | `rustls` (+ `rustls-native-certs`) | MIT OR Apache-2.0 / ISC | no OpenSSL; FIPS path via `aws-lc-rs` later (BL-0006) |
| OTLP types | `opentelemetry-proto` | Apache-2.0 | the official generated types |
| Protobuf | `prost` | Apache-2.0 | used by the above |
| gzip | `flate2` (pure-Rust backend) | MIT OR Apache-2.0 | no C toolchain |
| Config | `serde`, `toml` | MIT OR Apache-2.0 | already in use / standard |
| IDs | `ulid` or `uuid` | MIT | batch ids in logs |

All OSI-licensed, all buildable offline from vendored sources; `cargo deny` enforces the list (CI,
ADR-0012). Versions are pinned in `Cargo.lock`.

## 9. Risks found while designing

- **R1 — state saves fail on Windows today.** `state.rs` flushes the directory by opening it as a
  file, which Windows refuses without special flags. On Windows the directory flush is skipped (the
  rename is already durable there) or done with the right flag; Sc4 runs on Windows to prove it.
- **R2 — unbounded reads.** `complete_lines_from` reads to end of file into memory. A large backlog
  (an hour-long outage, Sc5) would blow D9. The reader must read in bounded chunks up to the open
  batch's remaining room.
- **R3 — a single line larger than the batch byte cap.** Lines are capped (ADR-0007 §2,
  `quarrel.line.truncated_bytes`) below the smallest profile's byte cap, so a batch always has room
  for at least one line.

## 10. Open questions

- **OQ8 — Windows file sharing (was SOW OQ5).** Rust opens files on Windows with read, write and
  delete sharing allowed, so the shipper itself should not block a writer or a rotation. What remains
  is how common Windows writers open their logs, and what rename and delete look like while the
  shipper holds the file. Settle by an experiment on the Windows VM (BL-0025): a writer appending,
  the shipper tailing, then rename, delete and recreate; record what each step does.
- **OQ9 — Quarantine bounds.** Default cap (proposal: 100 MiB or 1,000 batches, oldest dropped with a
  `buffer_overflow` gap), and whether to keep it inside the D9 disk budget.
- **OQ10 — Poll interval.** `min(250 ms, max_wait / 2)` is a proposal; confirm it against CPU in Sc10.

## 11. How the scenarios map to tests

| Scenario | Where it is proven |
|---|---|
| Sc1, Sc2, Sc3, Sc7, Sc10a | shipper integration tests against the demo consumer's test mode (D6) |
| Sc4 | a kill-loop harness on each OS in CI, checking the §4 table |
| Sc5 | 2-minute outage in CI; 60-minute run per release candidate |
| Sc6 | test mode scripted through every row of §5 |
| Sc8 | a test collector with a self-signed CA; log output scanned for the token |
| Sc9 | the three-OS pipeline (ADR-0012) |
| Sc10 | soak with peak memory and CPU recorded against D9 |
| core logic | unit tests in `quarrel-core`: batching limits, ledger never passing an ack, response classes, mapping |

## 12. Order of work (for the engineering plan)

1. `quarrel-core`: config + profiles, batch builder, ledger, response classifier, OTLP mapping. Unit
   tested, no I/O.
2. Demo consumer receiver and test mode (BL-0019 step 1): the collector every later test needs.
3. Shipper reader and sender threads, bounded reads (R2), Windows-safe state (R1), quarantine.
4. Scenario tests Sc1 → Sc10a; CI legs as they come online (BL-0025).
5. README: the shipper row claims shipping only when the DoD passes (ADR-0010).
