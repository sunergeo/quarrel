# SOW: Ensure every complete log line reaches an OTLP collector at least once, through crashes, restarts and outages

**Status:** In Architecture
**Created:** 2026-11-13
**Last updated:** 2026-11-14
**Owner:** SB
**Big idea:** BI-02 (never lose a line)

---

## 1. Outcome

An operator points the shipper at one or more log files and an OTLP/HTTP collector. Every complete
line written to those files arrives at the collector as a log record that says which host, file,
file fingerprint and byte offset it came from. Killing the shipper at any moment, restarting it, or
taking the collector down for an hour loses nothing: when things recover, every line is there,
duplicates are possible only for the batch that was in flight, and the collector can drop them by
`(host, fingerprint, offset)`. The same behaviour holds on macOS, Linux and Windows.

## 2. Why this matters

Shipping is the shipper's reason to exist; today it only prints lines locally. ADR-0006 makes quarrel
production-grade tooling. This SOW delivers the core guarantee, at-least-once delivery with
ack-before-advance, against a real wire protocol (ADR-0007).

It is necessary but not sufficient for production use: rotation (NG1), a separate disk buffer (NG3),
health (NG4), FIPS TLS where required (NG6) and packaging (NG7) are also needed.

## 3. Scope

### In scope

- Components: `crates/quarrel-shipper` (and `quarrel-core` only if ADR-0002's shared event model is
  needed now; otherwise it stays planned).
- Concretely:
  - A `ship` mode: tail a configured list of files and export complete lines as OTLP/HTTP logs
    (protobuf, gzip), with the record mapping of ADR-0007 §2.
  - Batching by line count, byte size and interval (ADR-0007 §6), chosen by profile with per-setting
    overrides (D10).
  - Ack-before-advance (ADR-0007 §3) with the existing atomic state save (M2).
  - Every response in ADR-0007 §4, including local quarantine of rejected batches and `quarrel.gap`
    records.
  - HTTPS with verification on by default, a bearer token or headers from config; the token never
    appears in output.
  - Configuration from a TOML file, with the same keys overridable from environment variables.
  - A foreground `run` mode with ADR-0013's seams: one stop token and a bounded clean stop, a
    single-instance lock, absolute default paths, meaningful exit codes, readiness, a log-sink
    setting (architecture D18–D20). `check-config` validates without running.
  - The test collector: `quarrel-demo`'s receiver and test mode (D6, ADR-0009), recording what it
    receives and returning any response on demand. Its dashboard is not in this SOW's scope.
  - Builds and passes the scenarios on macOS, Linux and Windows.

### Out of scope (explicit)

- **NG1 — File discovery, rename/rotation, missing files.** Disposition: → roadmap M3 (BL-0002).
  Until then a file that is rotated away or deleted while the collector is down can lose lines;
  that is why this SOW alone is not production-ready.
- **NG2 — Truncation (copy-truncate).** Disposition: → M4.
- **NG3 — A disk buffer separate from the source files.** Here the source file is the buffer
  (offsets simply don't advance). A separate bounded buffer is needed once rotation can remove
  unread data. Disposition: → the rotation SOW.
- **NG4 — Health metrics and a consumer heartbeat** (ADR-0007 §8). Disposition: → its own SOW;
  a consumer's own heartbeat or alerting is its adapter's job (ADR-0007 §8).
- **NG5 — Docker, maillog and other sources.** Disposition: later SOWs.
- **NG6 — FIPS-validated TLS.** Disposition: → BL-0006.
- **NG7 — Packaging: container image changes, systemd/launchd/Windows service units, signed
  releases.** Disposition: → M8; service integration → BL-0026 (ADR-0013).
- **NG8 — OTLP/gRPC and JSON encodings.** Disposition: later, if a consumer needs them.

## 4. Acceptance Criteria (Definition of Done)

Run against the test collector (D6) and, once, against a stock OpenTelemetry Collector. "Lines in
the file" and "records received" are compared by the dedupe key `(host.name,
quarrel.file.fingerprint, quarrel.file.offset)`.

- [ ] **Sc1 — Lines arrive with their identity.** Append 3 lines to a shipped file. Expected: within
  one batch interval + 5 s the collector holds 3 records whose body, `log.file.path`,
  `quarrel.file.fingerprint`, `quarrel.file.offset`, `host.name` and UTC `observed_time` match the
  file. Test path: integration test against the test collector.
- [ ] **Sc2 — A partial line waits.** Write `"half"` with no newline, wait two batch intervals, then
  write `"way\n"`. Expected: nothing is sent until the newline; then one record, `halfway`, at the
  offset where `half` began.
- [ ] **Sc3 — Restart resumes, without resending.** Ship 100 lines; stop the shipper cleanly; append
  50; start it. Expected: the collector receives exactly the 50 new lines after the restart.
- [ ] **Sc3a — Clean stops, one instance.** Send a stop (Ctrl-C / `SIGTERM`; Windows: console close)
  while a batch is in flight, with the collector answering slowly. Expected: the shipper exits within
  the stop deadline with code 0; on restart, no line is lost and only the unacknowledged batch is
  re-sent. Starting a second shipper on the same state folder fails with exit code 2 and a message
  naming the lock. Test path: integration test on all three OSes.
- [ ] **Sc4 — `kill -9` loses nothing.** Ship a file growing at 1,000 lines/s; send `SIGKILL`
  (Windows: `TerminateProcess`) at 20 random moments, restarting each time; then let it drain.
  Expected: every line in the file is received at least once; duplicates exist only for batches in
  flight at a kill; no saved offset is ever beyond the last acknowledged line. Test path: scripted
  soak; offsets logged and checked against the collector's acknowledgements.
- [ ] **Sc5 — An hour-long outage.** Stop the collector for 60 minutes while lines keep arriving;
  start it again. Expected: during the outage offsets do not move and the shipper retries with
  backoff capped at 60 s, honouring `Retry-After`; within 5 minutes of recovery every line written
  during the outage has arrived. (A 2-minute variant runs in CI; the 60-minute run is done once per
  release candidate.)
- [ ] **Sc6 — Every response is handled as ADR-0007 §4 says.** The test collector returns, in turn:
  `400`, `401`, `403`, `413`, `429` with `Retry-After`, `503`, and `200` with rejected records.
  Expected per response: quarantined + gap (400, partial rejection), stopped + reported (401/403),
  split and resent (413), backed off then delivered (429/503); in no case does an offset advance
  past an unacknowledged line.
- [ ] **Sc7 — Awkward lines.** A 1 MiB line and a line with invalid UTF-8. Expected: the long line
  arrives cut at the configured cap with `quarrel.line.truncated_bytes`; the invalid bytes arrive as
  U+FFFD; neither stalls the file.
- [ ] **Sc8 — Transport.** Export to an HTTPS collector with a self-signed certificate. Expected:
  refused unless that CA is configured; accepted when it is; the bearer token never appears in the
  shipper's output or logs.
- [ ] **Sc9 — Three platforms.** Sc1–Sc4 and Sc6 pass on macOS, Linux and Windows. Test path: the CI pipeline (D8, ADR-0012).
- [ ] **Sc10a — Batch profiles.** Under each profile, a batch closes at the right limit (lines, raw
  bytes, or wait from its first line); an override replaces only its own field; the effective values
  and their source appear at startup; Sc1 and Sc2 also pass under `live`. Test path: integration
  tests against the test collector.
- [ ] **Sc10b — Many files.** Configure 400 files, each receiving lines. Expected: memory stays
  within D9 and does not grow with the file count; open file handles stay under the cap; with
  `max_files = 256` exactly 256 are tracked and the shipper reports the limit in its logs and health
  (and refuses to start under `strict`); no file is starved (every tracked file's lines arrive within
  a few batch intervals). Test path: integration test against the test collector, on all three OSes.
- [ ] **Sc10 — Resource budget.** Shipping 1,000 lines/s for 10 minutes, and buffering through Sc5,
  stays within the D9 budget (≤ 64 MiB resident, < 5% of one core at 1,000 lines/s). Test path: soak with peak RSS recorded.
- [ ] **README reflects this outcome** (ADR-0010): the shipper row says it ships over OTLP at least
  once (and no more than is proven); commands and configuration are documented;
  `scripts/check-readme.sh` passes.

## 5. Architectural notes

- Contracts (source of truth): ADR-0007 (wire format, attribute names, ack and response rules);
  ADR-0005 §5 (output contracts are versioned and documented in the repo).
- Requirements: ADR-0006 §3. The shipper invariant (ADR-0002 §2) is the one this SOW proves.
- Existing code reused: `scan` (complete lines with byte offsets), `state` (atomic offset saves),
  `fingerprint` (sha256 of the first bytes).

| ID | Decision | Why / ruling |
|---|---|---|
| D1 | OTLP/HTTP, protobuf, gzip is the only output | SB 2026-11-13; ADR-0007 §1 |
| D2 | "Acknowledged" = `200` with no rejected records | ADR-0007 §3 |
| D3 | Dedupe key `(host.name, quarrel.file.fingerprint, quarrel.file.offset)` | ADR-0007 §2 |
| D4 | Plain TLS now; FIPS later | SB 2026-11-13; BL-0006 |
| D5 | macOS, Linux and Windows are all supported for the shipper | SB 2026-11-13; ADR-0006 §3 |
| D6 | The test collector is `quarrel-demo`'s test mode; one run also goes against a stock OpenTelemetry Collector | SB 2026-11-13; ADR-0009 §2–§3 |
| D7 | Synchronous shipper: a reader/batcher thread and a sender thread joined by a channel; blocking HTTP client; quarrel-core does no I/O | SB 2026-11-14; ADR-0011 |
| D8 | CI before promotion: Jenkins on a CentOS VM (coordinator + Linux leg), a Windows VM and SB's laptop (macOS) over SSH; rollup requires all three, macOS waivable only when unavailable | SB 2026-11-14; ADR-0012; BL-0025 |
| D9 | Resource budget (starting target): ≤ 64 MiB resident memory and < 5% of one core at 1,000 lines/s; disk-buffer cap configurable, default 1 GiB. Memory is enforced (the service unit's `MemoryMax=`), CPU is reported. The first soak's measured peak is written here, and the target tightened if it is far below | SB 2026-11-14 |
| D10 | Batching is chosen by named profile, with per-setting overrides: `balanced` (default: 1,000 lines / 1 MiB raw / 1 s), `throughput` (5,000 / 5 MiB / 5 s), `live` (500 / 512 KiB / 250 ms). Explicit field > profile > default; same keys in env and file; per destination; effective values and their source logged at startup and reported in health; impossible values refused, risky ones warned; the wait timer starts at a batch's first line. No adaptive batching for now | SB 2026-11-14 |
| D11 | Event time: the shipper sends only the time it read a line (`observed_time`); receivers order by it and, within a file, by offset. A timestamp parser, if ever needed, is a separate opt-in item | SB 2026-11-14 |

## 6. Open Questions

- ~~**OQ1 — Test collector.** Write a small in-repo test receiver (records batches, returns scripted
  responses), or drive a stock `otelcol` with a file exporter? The in-repo one is needed for Sc6
  either way; the stock one proves interoperability.~~ **Resolved 2026-11-13 → D6** (ADR-0009 §2).
- ~~**OQ2 — CI before M8.** Sc9 needs a three-OS CI matrix now, not at M8. Where does it run, given
  gitolite is the system of record (ADR-0001)? GitHub Actions on the mirror is the obvious host;
  results would be advisory, not a gate.~~ **Resolved 2026-11-14 → D8** (ADR-0012).
- ~~**OQ3 — Resource budget.** What memory (and CPU) ceiling should the shipper hold on a production
  host? The hardened service unit will set `MemoryMax=`; it needs a number.~~ **Resolved 2026-11-14 → D9.**
- ~~**OQ4 — Batch defaults.** Line, byte and interval defaults (a common receiver limit is 5,000 lines, 5 MB,
  5 s).~~ **Resolved 2026-11-14 → D10.**
- **OQ5 — Windows file semantics.** Reading a file another process is writing, and later rotating,
  needs the right sharing flags (`FILE_SHARE_DELETE`); confirm before Sc9.
  **Transferred 2026-11-14 → Architecture OQ8** (an experiment on the Windows VM).
- ~~**OQ6 — I/O model and HTTP stack.** Synchronous poll loop with a blocking client (for example
  `ureq` + rustls), or async (Tokio + `reqwest`)? The probe's question,
  BL-0003, is the same one; decide them together.~~ **Resolved 2026-11-14 → D7** (ADR-0011).
- ~~**OQ7 — Event time.** ADR-0007 leaves `time_unix_nano` unset because the shipper does not parse
  lines. Receivers then order by `observed_time` and, within a file, by offset; confirm that is
  enough, or whether an optional timestamp-parsing hook is needed later.~~ **Resolved 2026-11-14 → D11.**

- **OQ8 — Windows file sharing** (from OQ5). Raised in `Architecture/shipping-architecture.md` §10.
- **OQ9 — Quarantine bounds.** Raised in `Architecture/shipping-architecture.md` §10.
- **OQ10 — Poll interval.** Raised in `Architecture/shipping-architecture.md` §10.

## 7. Release notes draft

- You can now ship log files to any OpenTelemetry (OTLP/HTTP) collector. Every line carries its
  host, file and position, and nothing is lost if the shipper crashes, restarts, or the collector
  is down for a while.

## 8. Feature flag

No flag — `ship` is a new mode of a binary that is not deployed anywhere yet; there is no existing
behaviour to protect. The existing `scan` and `tail` modes are unchanged.

## 9. Lineage / Source Documents

- Governance: `../../../CLAUDE.md`
- Contracts (source of truth): `../../adr/ADR-0007-quarrel-shipper-delivers-over-otlp-http-and-advances-only-on-acknowledgement.md`
- Requirements: `../../adr/ADR-0006-quarrel-is-production-grade-observability-tooling.md`
- Backlog item(s): BL-0002 (rotation, NG1), BL-0003 (I/O model, OQ6), BL-0006 (FIPS, NG6), BL-0007
  (the output contract, documented for consumers)
- Related ADRs: ADR-0002, ADR-0005, ADR-0006, ADR-0007

---

## Revisions

- 2026-11-14 — Run modes (ADR-0013): foreground `run` + seams in scope, Sc3a added; service integration
  → BL-0026.
- 2026-11-14 — Sc10b (many files) added with architecture D16/D17 (SB: guard against rogue file
  counts).
- 2026-11-14 — OQ7 resolved → D11; OQ5 transferred to Architecture OQ8.
- 2026-11-14 — OQ4 resolved → D10 (batch profiles balanced/throughput/live, overrides); Sc10a added.
- 2026-11-14 — OQ3 resolved → D9 (64 MiB, < 5% core, 1 GiB buffer default).
- 2026-11-14 — OQ2 resolved → D8 (three-OS CI before promotion, Jenkins; ADR-0012).
- 2026-11-14 — OQ6 resolved → D7 (sync shipper, I/O-free core; ADR-0011).
- 2026-11-13 — OQ1 resolved → D6 (the demo consumer's test mode, ADR-0009).
- 2026-11-13 — Created from SB's rulings (purpose, OTLP, first SOW = first real shipping, all three
  platforms).

## Phase Transitions

- 2026-11-13 — Status: Planned. SOW created.
- 2026-11-14 — Status: Planned → In Architecture. Every question needing SB's ruling is settled
  (D7–D11); OQ5 continues as Architecture OQ8. Architecture note:
  `Architecture/shipping-architecture.md`.
