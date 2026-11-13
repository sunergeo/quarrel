---
id: BL-0024
title: "Candidate quarrel-ping mode: two-ended measurement with a responder, for one-way latency and the return path"
type: Process-idea
status: New
horizon: someday
big_idea: BI-01
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: quarrel-ping (a mode, not a new tool); ADR-0004
disposition: null
---

# BL-0024 — Candidate quarrel-ping mode: two-ended measurement

## Idea

A small quarrel responder runs at the far end, so two quarrel hosts measure each other (in the style
of TWAMP, the standard two-way active measurement protocol). That yields one-way latency in each
direction and a view of the return path, which single-ended tracing cannot see. Path asymmetry is a
common hidden cause.

## Why it fits quarrel

- Extends quarrel-ping's purpose (ADR-0008 §2: routing, including whether it differs by direction).
- Within a defined system the operator controls both ends, so a responder is deployable.

## Learning

The `clock_sync` lesson (BL-0014) becomes product-critical: one-way delay needs synchronised clocks,
and the error bounds must be reported with each figure. TWAMP's design is a model to read.

## Before it starts

quarrel-ping P3 (paths) is done.

## Log

- 2026-11-13 — Captured from the expansion-candidates discussion (candidate 3).
