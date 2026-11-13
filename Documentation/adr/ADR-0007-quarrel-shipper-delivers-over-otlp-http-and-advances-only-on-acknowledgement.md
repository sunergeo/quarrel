# ADR-0007 — quarrel-shipper delivers over OTLP/HTTP and advances only on acknowledgement

- **Status:** **Proposed 2026-11-13.** SB ruled the protocol (OTLP; the consumer adapts). The
  mapping and response rules below are the recommended detail; they become Accepted when the first
  shipping SOW's DoD passes against a real collector.
- **Date:** 2026-11-13
- **Deciders:** SB
- **Scope:** Repo-level. The shipper's only network output: wire format, the identity each line
  carries, what counts as an acknowledgement, and how each response is handled.
- **Related:** ADR-0005 (open formats, no consumer-specific code); ADR-0006 (production
  requirements); BL-0006 (FIPS TLS); BL-0007 (the contract, documented for consumers).

## Context

ADR-0005 chose open formats. Log pipelines often have their own ingest protocols, typically gzip
JSON batches with a per-host token and an "accepted" status code. SB, 2026-11-13: quarrel speaks
OTLP only; a consumer whose ingest speaks something else maps OTLP to it on its own side. The
shipper's invariant needs a precise meaning of "acknowledged", and every consumer needs each line
to carry the identity it dedupes on.

## Decision

1. **One output: OTLP/HTTP logs** (`POST <endpoint>/v1/logs`, protobuf, gzip). gRPC and JSON
   encoding may follow; protobuf over HTTP is the baseline because every OTLP receiver must accept
   it. quarrel contains no consumer-specific output. A consumer with another protocol puts an
   adapter in front of its storage, on its side.
2. **Each line is one log record, and carries its identity:**

   | OTLP field | Value |
   |---|---|
   | Resource `service.name` | `quarrel-shipper` |
   | Resource `service.version` | the build version |
   | Resource `host.name` | the configured host identity (not guessed from the OS when configured) |
   | Resource `deployment.environment.name` | `QUARREL_ENV` |
   | Resource, extra | the configured identity labels (ADR-0005 §1) |
   | `body` | the line as a string: bytes up to `\n`, without it; invalid UTF-8 replaced by U+FFFD |
   | `observed_time_unix_nano` | when the shipper read the line (UTC) |
   | `time_unix_nano` | unset: the shipper does not parse event time (parsing is downstream) |
   | `log.file.path`, `log.file.name` | the file (OpenTelemetry semantic conventions) |
   | `quarrel.file.fingerprint` | `sha256:<hex>` of the file's first bytes |
   | `quarrel.file.fingerprint_len` | how many bytes the fingerprint covers |
   | `quarrel.file.offset` | byte offset where the line starts |
   | `quarrel.source` | `file` (later `docker`, …) |
   | `quarrel.line.truncated_bytes` | present only when a line over the size cap was cut |

   The dedupe key a consumer may rely on is `(host.name, quarrel.file.fingerprint,
   quarrel.file.offset)`. These attribute names are part of quarrel's versioned output contract
   (ADR-0005 §5).
3. **Acknowledged means:** HTTP `200` whose `ExportLogsServiceResponse` has no `partial_success`, or
   `partial_success.rejected_log_records == 0`. Only then may offsets advance, and only up to the
   last line of that batch in each file.
4. **Every other response is handled explicitly, and none advances an offset:**

   | Response | Shipper does |
   |---|---|
   | `200` with rejected records > 0 | treat as a rejected batch: quarantine it locally, report a gap, carry on with the next lines |
   | `400` | quarantine the batch locally, report it in health and as a gap, never resend it unchanged |
   | `401`, `403` | stop sending, keep reading into the buffer, report unhealthy with the reason |
   | `413` | split the batch and resend the halves |
   | `429`, `502`, `503`, `504`, timeouts, connection errors | retry with exponential backoff and jitter, honour `Retry-After`, cap at 60 s; keep buffering |
   | any other `5xx` | as above |

5. **Gaps are log records too**: event name `quarrel.gap`, attribute `quarrel.gap.kind`
   (`truncated`, `rotated_unread`, `buffer_overflow`, `decode_error`, `rejected`) and the affected
   file and offset range. Nothing is dropped without one.
6. **Batching:** a batch closes at a configured line count or byte size, or after a configured
   interval while lines are pending (defaults to be set from measurements; a receiver's limits, for
   example 5,000 lines / 5 MB / 5 s, are configuration, not constants).
7. **Transport:** HTTPS with certificate verification on by default; a bearer token or custom
   headers from configuration; secrets are never logged. Plain `http://` only when configured
   explicitly. FIPS mode is BL-0006.
8. **Health is not a second protocol.** The shipper exposes its health (last acknowledged export,
   buffer bytes, gaps total, per-file lag and staleness) as OTLP metrics on the same endpoint, and
   locally (status file or endpoint). How a consumer turns that into its own heartbeat or alerting
   is the consumer's adapter.

## Consequences

- The offset invariant becomes testable against any OTLP receiver: a test collector that returns
  each response in §3–§4 on demand is part of the shipping SOW's DoD.
- A consumer with its own ingest protocol builds a small OTLP/HTTP receiver that maps these
  records to its storage and dedupes on the key in §2. BL-0007 documents the contract for them.
- If OTLP turns out not to carry something a consumer needs, the answer is a new attribute in
  quarrel's versioned contract, not a consumer-specific output.
