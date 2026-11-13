---
id: BI-01
title: See the network as it is
state: simmering
opened: 2026-11-13
updated: 2026-11-13
---

# BI-01 — See the network as it is

**North star.** For a defined system, an operator can see what the network between its parts is
actually doing: the segments and who owns them, the routes taken and when they change, latency and
loss per hop over time, and where a bottleneck begins, with the evidence (ADR-0008).

**Done means.** quarrel-ping measures every declared path continuously, attributes problems to a
segment with stated confidence, reports route changes, and ships it all as OTLP; the TUI shows it
live. Further work is refinement, not capability.

## Outcome spine

1. 🟥 Ping one target, portable, no root (P1)
2. 🟥 Many targets, one socket, over time (P2)
3. 🟥 MTR-style paths with owners and segment attribution (P3)
4. 🟥 IPv6 (P4) · TCP/UDP probes (P5)
5. 🟥 Two-ended measurement: one-way latency and the return path (BL-0024)
6. 🟥 DNS as part of the path (BL-0023)

## Member items

ADR-0003, ADR-0004, ADR-0008 · BL-0003, BL-0004, BL-0016, BL-0017, BL-0018, BL-0023, BL-0024 ·
lessons BL-0009 to BL-0015, BL-0021

## Wake trigger

The shipper's first SOW is Done (BI-02), or a deployment needs path visibility first.
