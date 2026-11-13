---
id: BL-0010
title: "Optional lesson (quarrel-ping): latency statistics — summarising latency without lying"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module latency_stats); shapes quarrel-ping (P-step P2)
disposition: null
---

# BL-0010 — Optional lesson (quarrel-ping): latency statistics — summarising latency without lying

## Shapes

**quarrel-ping**, before **P2**. Module `latency_stats` in `crates/quarrel-lessons`, tests in `tests/latency_stats.rs`.

## Math it exercises

Σ, E[X], Var(X); Welford's recurrence; quantiles; log-scale buckets; exponential smoothing (RFC 3550 jitter).

## Why

ADR-0004 §5 defines loss, percentiles, jitter and roll-ups. The probe uses the `hdrhistogram` crate;
this lesson builds the ideas by hand to see why they work.

## Steps

1. Streaming mean and variance (Welford's method): one pass, no stored samples, numerically stable.
2. A log-linear (HDR-style) histogram from scratch: fixed relative error, bounded memory; check its percentiles against `hdrhistogram`.
3. Why a mean of means is wrong, and how sample-count weighting fixes roll-ups (ADR-0004 §5).
4. RFC 3550 jitter derived step by step (the 1/16 smoothed mean deviation) versus the mean of consecutive differences, on the same data.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). `hdrhistogram` is a dev-dependency only; the lesson's histogram is checked against it.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
