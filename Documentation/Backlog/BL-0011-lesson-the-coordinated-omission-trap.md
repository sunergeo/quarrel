---
id: BL-0011
title: "Optional lesson (quarrel-ping): coordinated omission — the classic latency-measurement trap"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module coordinated_omission); shapes quarrel-ping (P-step P2)
disposition: null
---

# BL-0011 — Optional lesson (quarrel-ping): coordinated omission — the classic latency-measurement trap

## Shapes

**quarrel-ping**, before **P2**. Module `coordinated_omission` in `crates/quarrel-lessons`, tests in `tests/coordinated_omission.rs`.

## Why

A tester that waits for each reply before sending the next probe sends fewer probes exactly when the
network is slow, so the slow period barely shows in its numbers. P2's send pacing must avoid this.

## Steps

1. Simulate a target with a 2-second stall and a closed-loop tester; compare its percentiles with the true latency distribution.
2. Fix 1: an open-loop sender on a fixed schedule, independent of replies.
3. Fix 2: correct recorded samples for the probes that should have been sent (the HdrHistogram approach), and when that is valid.
4. State the rule P2 follows, with the simulation as its evidence.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). P2's pacing design cites this lesson.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
