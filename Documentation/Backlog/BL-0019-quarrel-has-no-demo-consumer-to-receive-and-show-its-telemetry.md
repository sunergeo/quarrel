---
id: BL-0019
title: quarrel has no demo consumer, so there is nothing to send telemetry to or look at, and no controllable test collector
type: Process-idea
status: Triaged
horizon: now
big_idea: BI-02
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0009; crates/quarrel-demo (planned); shipping SOW D6
disposition: null
---

# BL-0019 — A demo consumer: OTLP receiver, test mode, React dashboard

## Summary

ADR-0009: one Docker image, `quarrel-demo`, that receives OTLP from both tools, doubles as the
shipping SOW's test collector, and serves a React dashboard. Demo, development and test only.

## Suggested order (each a SOW or a SOW increment)

1. **Receiver + test mode** first: it unblocks the shipping SOW (D6, Sc1–Sc10).
2. **Dashboard, shipper views:** live tail, lag, gaps, health.
3. **Dashboard, quarrel-ping views:** per-hop time graphs, segments and owners, route changes,
   attribution. After quarrel-ping's P2/P3.
4. **Image and compose file** for the demo, with the shipper (and later quarrel-ping) pointed at it.

## Log

- 2026-11-13 — Captured with ADR-0009.
