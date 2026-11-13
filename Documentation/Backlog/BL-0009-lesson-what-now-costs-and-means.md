---
id: BL-0009
title: "Optional lesson (quarrel-ping): clocks — what "now" costs and means on each OS"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module clocks); shapes quarrel-ping (P-step P1)
disposition: null
---

# BL-0009 — Optional lesson (quarrel-ping): clocks — what "now" costs and means on each OS

## Shapes

**quarrel-ping**, before **P1**. Module `clocks` in `crates/quarrel-lessons`, tests in `tests/clocks.rs`.

## Why

ADR-0004 §3–§4 make the probe time every sample with a monotonic clock and state its precision per
platform. This lesson measures what that precision actually is, before P1 claims any.

## Steps

1. Wall clock versus monotonic clock: why durations never use wall time (ADR-0004 §3).
2. Measure `Instant` on this machine: its resolution, and how long one read takes, on macOS, Linux and Windows.
3. Sleep overshoot: request 1 ms, 100 µs and 10 µs sleeps and histogram what you get; why send pacing can't trust `sleep`.
4. Kernel versus user-space receive timestamps (`SO_TIMESTAMP` and friends): how much time passes between a packet arriving and the code noticing.
5. Write the noise floor down: the smallest latency difference this machine can honestly report.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). The probe's per-platform precision claims (ADR-0004 §4) cite this lesson's measured noise floor.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
