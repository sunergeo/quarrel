---
id: BL-0004
title: quarrel has no network probe yet, only the shipper
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-12
affected: ADR-0002; ADR-0003; ADR-0004; ADR-0005; ROADMAP.md (probe track)
disposition: null
---

# BL-0004 — quarrel has no network probe yet

## Summary

ADR-0002 makes quarrel one toolkit with a shipper and a probe, but only the shipper exists. This
item is the probe track's anchor in the funnel. `ROADMAP.md` lists its steps: workspace split, then
P1 to P6.

## Detail

- **What the probe is:** ADR-0002 (toolkit), ADR-0003 (portability, backends, clean-room
  provenance), ADR-0004 (measurement model, Proposed) and ADR-0005 (events and outputs).
- **Before code:** each step gets a SOW whose title names the behaviour (for example "you can ping
  one target with microsecond timing on macOS, Linux and Windows"). Its Definition of Done is a run
  of the binary against real targets, not merged commits.
- **Blocked by:** `BL-0003` (I/O model) for P2 onward.

## Triage notes

- 2026-11-12 — SB: direction accepted (ADR-0002, 0003, 0005); ADR-0004 Proposed. Horizon
  `someday` until the shipper's M3 lands; then promote the workspace split and P1 to SOWs.

## Log

- 2026-11-12 — captured and triaged.
