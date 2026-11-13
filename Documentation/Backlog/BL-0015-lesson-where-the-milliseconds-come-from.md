---
id: BL-0015
title: "Optional lesson (quarrel-ping): latency anatomy — where the milliseconds come from"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module latency_anatomy); shapes quarrel-ping (background)
disposition: null
---

# BL-0015 — Optional lesson (quarrel-ping): latency anatomy — where the milliseconds come from

## Shapes

**quarrel-ping**, at any point (not tied to a P-step). Module `latency_anatomy` in `crates/quarrel-lessons`, tests in `tests/latency_anatomy.rs`.

## Math it exercises

queueing: Little's law L = λW; M/M/1 waiting time as a Markov birth–death process.

## Why

Optional background for reading the probe's numbers.

## Steps

1. Propagation, serialization, queuing and processing delay, each estimated for a real path.
2. The bandwidth-delay product and what it means for a single TCP flow.
3. A small bufferbloat simulation: queuing delay climbing under load, and why idle latency hides it.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). Optional at any point.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
