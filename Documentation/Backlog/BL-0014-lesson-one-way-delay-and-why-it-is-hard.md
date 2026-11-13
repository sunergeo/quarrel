---
id: BL-0014
title: "Optional lesson (quarrel-ping): clock synchronisation — one-way delay and why it is hard"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module clock_sync); shapes quarrel-ping (background)
disposition: null
---

# BL-0014 — Optional lesson (quarrel-ping): clock synchronisation — one-way delay and why it is hard

## Shapes

**quarrel-ping**, at any point (not tied to a P-step). Module `clock_sync` in `crates/quarrel-lessons`, tests in `tests/clock_sync.rs`.

## Math it exercises

a small system of equations (offset and delay from four timestamps); error bounds.

## Why

The probe reports round-trip time. This lesson shows why one-way delay is a different, harder
measurement.

## Steps

1. The NTP four-timestamp exchange: derive offset and round-trip delay.
2. Why one-way delay needs synchronised clocks, and how asymmetric paths make the offset ambiguous.
3. How far off a typical NTP-synced pair of hosts is, and what that does to a one-way figure.
4. Write down why the probe reports round trips.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). Optional at any point; it explains a design choice rather than gating a step.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
