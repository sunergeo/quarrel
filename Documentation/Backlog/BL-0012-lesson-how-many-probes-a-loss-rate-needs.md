---
id: BL-0012
title: "Optional lesson (quarrel-ping): loss confidence — how many probes it takes to claim a loss rate"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module loss_confidence); shapes quarrel-ping (P-step P2)
disposition: null
---

# BL-0012 — Optional lesson (quarrel-ping): loss confidence — how many probes it takes to claim a loss rate

## Shapes

**quarrel-ping**, before **P2**. Module `loss_confidence` in `crates/quarrel-lessons`, tests in `tests/loss_confidence.rs`.

## Why

ADR-0004 §5–§6 define loss and require rate limiting to be surfaced. Zero lost out of 100 does not
prove 0% loss; this lesson puts numbers on how sure a loss figure is.

## Steps

1. Binomial confidence intervals: the naive interval, then the Wilson score interval, and where the naive one fails (0 or few losses).
2. How many probes are needed to tell 0.1% loss from 1% at 95% confidence.
3. Simulate ICMP reply rate limiting at one hop: loss that appears at that hop and not at later hops (ADR-0004 §6).

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). P2 reports loss with its confidence, using the interval this lesson validates.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
