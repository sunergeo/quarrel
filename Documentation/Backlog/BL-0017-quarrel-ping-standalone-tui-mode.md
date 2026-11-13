---
id: BL-0017
title: quarrel-ping has no standalone terminal UI for watching a path live (planned, future)
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0008 §4; quarrel-ping
disposition: null
---

# BL-0017 — Standalone TUI mode for quarrel-ping

## Summary

SB, 2026-11-13: "I definitely want a standalone TUI mode for the core tool (future) so users can
start it running and watch stats in real time." ADR-0008 §4 records it as planned.

## Shape (to become a SOW when its turn comes)

- Starts with one command and a target; needs no collector, config file or privileges (ADR-0003 §2).
- Shows, live: the hop list with owner and segment (ADR-0008 §5), per-hop latency (min/avg/max and
  percentiles), loss with its confidence, a scrolling time graph per hop or for the destination,
  and the segment-attribution verdict in words.
- Reads the same measurement engine as the OTLP exporter, so the TUI and the dashboards can never
  disagree. Can export the shareable summary (ADR-0008 §3).
- Runs on macOS, Windows and Linux terminals.

## Depends on

P2 (continuous measurement, history), P3 (paths, attribution), BL-0016 (ownership data).

## Log

- 2026-11-13 — Captured.
