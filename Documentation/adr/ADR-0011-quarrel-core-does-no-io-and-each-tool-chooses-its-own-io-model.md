# ADR-0011 — quarrel-core does no I/O, and each tool chooses its own I/O model

- **Status:** **Accepted 2026-11-14.** SB's ruling (shipping SOW OQ6).
- **Date:** 2026-11-14
- **Deciders:** SB
- **Scope:** Repo-level. How the shared core relates to I/O, and which model each tool uses.
- **Related:** ADR-0002 (toolkit, shared core); ADR-0003 §3 (the network tool's packet code is pure);
  ADR-0007 (the shipper's delivery invariant); BL-0003 (quarrel-ping's model, still open).

## Context

A Rust program waits on files, sockets and timers either synchronously (blocking calls; threads for
concurrency) or asynchronously (`async`/`await` on a runtime such as Tokio). The two do not mix
freely: async code is called from async code, and a core library that chooses one forces it on
every tool that uses it. The tools have different shapes. The shipper does a little concurrency
(a few files, one request in flight, a few timers) and its value is a provable ordering invariant.
The demo consumer is an HTTP server. quarrel-ping juggles many targets, timers and a shared socket.

## Decision

1. **quarrel-core does no I/O.** The event model, identity labels, batching rules, offset
   bookkeeping, OTLP encoding and similar logic are pure functions and data types: given inputs,
   they return outputs, and never read a file, open a socket or sleep. It depends on no async
   runtime. (ADR-0003 §3 already holds the network tool's packet code to this rule.)
2. **Each tool chooses its own I/O model** around that core, for its own reasons, and records it:
   - **quarrel-shipper: synchronous.** Two threads joined by a channel: a reader/batcher that polls
     files and builds batches, and a sender that POSTs, waits for the acknowledgement, retries with
     backoff and reports back so offsets are saved only after acknowledgement. A blocking HTTP client
     (for example `ureq` with rustls). Reason: the at-least-once invariant is easiest to prove when
     the order of events is visible in sequential code, and the dependency tree stays small for
     offline, audited builds (ADR-0006).
   - **quarrel-demo: asynchronous**, as an HTTP server with live views (ADR-0009).
   - **quarrel-ping: decided at P1** (BL-0003), from its own concurrency needs.
3. **Revisit the shipper's model** only if it needs many concurrent destinations or streams, and
   record that as an amendment here.

## Consequences

- Core logic is tested without a runtime, a network or a clock, which makes the shipper's ordering
  invariant testable in isolation.
- Each tool owns its own runtime dependencies; the shipper's audit surface does not include an
  async runtime.
- A tool that wants async does not drag the others with it.
