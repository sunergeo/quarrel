---
id: BL-0013
title: "Optional lesson (quarrel-ping): path simulation — traceroute without sockets"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module path_simulation); shapes quarrel-ping (P-step P3)
disposition: null
---

# BL-0013 — Optional lesson (quarrel-ping): path simulation — traceroute without sockets

## Shapes

**quarrel-ping**, before **P3**. Module `path_simulation` in `crates/quarrel-lessons`, tests in `tests/path_simulation.rs`.

## Math it exercises

graphs; hashing (how routers split flows across paths).

## Why

P3 measures paths MTR-style (ADR-0004 §1, §7). An in-memory network makes the mechanics visible and
deterministic, with no root and no real routers.

## Steps

1. Simulated routers that decrement TTL and answer with Time Exceeded, quoting the original header.
2. Match replies to probes by the quoted header (ADR-0004 §2), including late and out-of-order replies.
3. ECMP load balancing that hashes flow fields; watch classic traceroute see a path that doesn't exist.
4. Paris-style flow pinning: hold the flow identifier constant and the path becomes stable.

## Rules

Optional, never on the shipping path, tested, built from public sources (BL-0008 Rules apply). Shares no code with the probe's packet module; the simulator's packets are deliberately simplified.

## Log

- 2026-11-13 — Captured at SB's request (one item per lesson, organised by the utility it shapes).
