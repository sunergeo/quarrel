# ADR-0005 — quarrel emits one vendor-neutral, timestamped event stream

- **Status:** **Accepted 2026-11-12.** Direction only; the event schema and the outputs are not
  built yet.
- **Date:** 2026-11-12
- **Deciders:** SB
- **Scope:** Repo-level. What quarrel's output looks like and what it may depend on downstream.
- **Related:** ADR-0002 (toolkit, `quarrel-core`); ADR-0004 (what the probe's numbers mean).

## Context

The shipper's job is to deliver log lines to an ingest endpoint; the probe's is to deliver
measurements. A reader gets the most from them when the two can be correlated, for example "the error
burst at 14:02 lines up with 30% loss at hop 6, seen from site A". That needs the same clock
convention and the same identity labels on both streams.

quarrel is public and meant to be used by more than one consumer. Any consumer's private protocol
built into the tool would make it a component of that consumer rather than a tool of its own.

## Decision

1. **One event model for both binaries**, defined in `quarrel-core`.
   - Every event carries a UTC timestamp in RFC 3339 with an explicit offset (`Z`); never a
     zone-less time.
   - Every event carries a set of identity labels: user-defined key/value pairs such as site, host,
     target and hop, configured, never hard-coded.
   - Every event carries an event kind and a schema version.
2. **Outputs use open formats only:**
   - **NDJSON** files: one event per line; the simplest output, and tail-able by any shipper,
     including quarrel's own.
   - **OTLP** (OpenTelemetry): logs for the shipper's lines and the probe's events, metrics for the
     probe's measurements.
   - **Prometheus** exposition: an optional pull endpoint for the probe's metrics.
3. **Events and numbers take different paths.** State changes, threshold breaches and path changes
   are *events*. Per-probe samples are aggregated into *metrics*; they are not streamed one by one
   as log lines.
4. **No consumer-specific integrations in this repo.** quarrel names no particular backend, and
   carries no private protocol or hard-coded destination. A consumer that needs something else
   writes an adapter on its own side, against the documented formats.
5. **The output formats are versioned and documented** in the repo, so a consumer can depend on
   them.

## Consequences

- **The shipper's current target is an abstract "ingest endpoint"** (M5 in its roadmap). That
  endpoint's acknowledgement contract, which the shipper's offset invariant depends on, has to be
  written down as part of this event model before M5.
- **A consumer of quarrel pins a released version** and its documented output format, never a
  moving branch.
- **Dependencies point one way:** consumers may depend on quarrel; quarrel depends on no consumer.
