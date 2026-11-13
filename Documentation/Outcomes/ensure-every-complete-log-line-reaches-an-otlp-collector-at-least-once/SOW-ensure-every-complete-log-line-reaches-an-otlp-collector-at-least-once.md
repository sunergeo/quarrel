# SOW: Ensure every complete log line reaches an OTLP collector at least once, through crashes, restarts and outages

**Status:** Planned
**Created:** 2026-11-13
**Last updated:** 2026-11-13
**Owner:** SB
**Big idea:** —

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
  - Batching by line count, byte size and interval (ADR-0007 §6), all configurable.
  - Ack-before-advance (ADR-0007 §3) with the existing atomic state save (M2).
  - Every response in ADR-0007 §4, including local quarantine of rejected batches and `quarrel.gap`
    records.
  - HTTPS with verification on by default, a bearer token or headers from config; the token never
    appears in output.
  - Configuration from a TOML file, with the same keys overridable from environment variables.
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
  releases.** Disposition: → M8.
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
- [ ] **Sc9 — Three platforms.** Sc1–Sc4 and Sc6 pass on macOS, Linux and Windows. Test path: CI
  matrix (OQ2).
- [ ] **Sc10 — Resource budget.** Shipping 1,000 lines/s for 10 minutes, and buffering through Sc5,
  stays within the memory budget set in OQ3. Test path: soak with peak RSS recorded.

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

## 6. Open Questions

- ~~**OQ1 — Test collector.** Write a small in-repo test receiver (records batches, returns scripted
  responses), or drive a stock `otelcol` with a file exporter? The in-repo one is needed for Sc6
  either way; the stock one proves interoperability.~~ **Resolved 2026-11-13 → D6** (ADR-0009 §2).
- **OQ2 — CI before M8.** Sc9 needs a three-OS CI matrix now, not at M8. Where does it run, given
  gitolite is the system of record (ADR-0001)? GitHub Actions on the mirror is the obvious host;
  results would be advisory, not a gate.
- **OQ3 — Resource budget.** What memory (and CPU) ceiling should the shipper hold on a production
  host? The hardened service unit will set `MemoryMax=`; it needs a number.
- **OQ4 — Batch defaults.** Line, byte and interval defaults (a common receiver limit is 5,000 lines, 5 MB,
  5 s).
- **OQ5 — Windows file semantics.** Reading a file another process is writing, and later rotating,
  needs the right sharing flags (`FILE_SHARE_DELETE`); confirm before Sc9.
- **OQ6 — I/O model and HTTP stack.** Synchronous poll loop with a blocking client (for example
  `ureq` + rustls), or async (Tokio + `reqwest`)? The probe's question,
  BL-0003, is the same one; decide them together.
- **OQ7 — Event time.** ADR-0007 leaves `time_unix_nano` unset because the shipper does not parse
  lines. Receivers then order by `observed_time` and, within a file, by offset; confirm that is
  enough, or whether an optional timestamp-parsing hook is needed later.

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

- 2026-11-13 — OQ1 resolved → D6 (the demo consumer's test mode, ADR-0009).
- 2026-11-13 — Created from SB's rulings (purpose, OTLP, first SOW = first real shipping, all three
  platforms).

## Phase Transitions

- 2026-11-13 — Status: Planned. SOW created.
