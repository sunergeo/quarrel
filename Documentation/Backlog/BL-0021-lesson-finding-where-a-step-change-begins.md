---
id: BL-0021
title: "Optional lesson (quarrel-ping): change-point detection — finding where a step change begins"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module change_points); shapes quarrel-ping (P-step P3)
disposition: null
---

# BL-0021 — Optional lesson (quarrel-ping): change-point detection — finding where a step change begins

## Shapes

**quarrel-ping**, before **P3**. Module `change_points` in `crates/quarrel-lessons`, tests in `tests/change_points.rs`.

## Math it exercises

cumulative sums and the CUSUM statistic; hypothesis testing (false-alarm rate versus detection delay); likelihood ratios; noise versus signal in a time series.

## Why

ADR-0008 §3 asks quarrel-ping to name "the first hop where latency or loss steps up and stays up", and
to notice when a path's latency changes over time. Both are change-point problems: separating a real,
lasting shift from noise and single spikes. This lesson builds the method by hand before P3 relies on
it.

## Steps

1. Generate synthetic latency series with a known step (and with spikes that are not steps).
2. Naive thresholds first: why a fixed "above X ms" rule both misses real steps and fires on spikes.
3. CUSUM (Page's cumulative-sum test): accumulate deviations from a baseline, alarm when the sum
   crosses a threshold; derive the trade-off between false alarms and detection delay.
4. Two directions: steps up (degradation) and steps down (recovery).
5. Across hops instead of across time: apply the same idea along a path to find the first hop where
   a level shift begins and persists to the destination (ADR-0004 §6: a shift that does not persist
   is reply rate limiting, not a segment problem).
6. State the rule P3's attribution uses, with the lesson's false-alarm and delay figures as evidence.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). P3's
segment attribution cites this lesson.

## Log

- 2026-11-13 — Captured at SB's request.
