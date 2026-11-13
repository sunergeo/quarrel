---
id: BL-0003
title: Decide the probe's I/O model, async (Tokio) or a synchronous poll loop over non-blocking sockets
type: Standard-gap
status: New
horizon: next
big_idea: BI-01
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-12
affected: ADR-0003 §4; quarrel-ping (not yet built)
disposition: null
---

# BL-0003 — The probe's I/O model is undecided

## Summary

ADR-0003 puts each platform backend behind a trait, but does not decide how the probe waits on
sockets and timers. That choice shapes P2 (many targets on one socket) and must be made before it
starts.

## Detail

- **OQ1 — Async (Tokio) or synchronous?**
  - *Async:* the usual choice for many concurrent probes and timers, with a large ecosystem.
  - *Synchronous:* one loop over non-blocking sockets with readiness polling (`poll`/`kqueue`,
    e.g. via `mio`) and a timer wheel. This matches the shipper's deliberate synchronous design and
    teaches more about how async works underneath, but it is harder to get right on Windows.
- **OQ2 — Can the Windows `IcmpSendEcho2Ex` backend fit the same model?** It completes through an
  event or an APC callback, not socket readiness. The trait must allow a backend that does its own
  waiting and matching (ADR-0004, Consequences).
- **OQ3 — Does the choice leak into `quarrel-core`?** The shipper is synchronous. If the probe goes
  async, the shared core must stay usable from both (for example a blocking sink API, with an async
  adapter in the probe).

## Triage notes

- 2026-11-12 — captured while recording ADR-0002 to ADR-0005; horizon `next` (blocks P2). Decide
  with an ADR once P1 has exercised a single socket on macOS and Windows.

## Log

- 2026-11-12 — captured.
