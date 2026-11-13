---
id: BI-02
title: Never lose a line
state: on
opened: 2026-11-13
updated: 2026-11-13
---

# BI-02 — Never lose a line

**North star.** Every complete line a host writes to its logs reaches the operator's collector at
least once, through crashes, restarts, outages and rotation, and anything that cannot be delivered
is reported as a gap rather than silently dropped (ADR-0006, ADR-0007).

**Done means.** quarrel-shipper meets ADR-0006's production requirements on macOS, Linux and
Windows: delivery, rotation and truncation, a bounded buffer, honest health, TLS (FIPS where
required) and a packaged release.

## Outcome spine

1. 🟥 Ship to an OTLP collector at least once (SOW Planned:
   `ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once`)
2. 🟥 Survive rotation and missing files (M3, BL-0002)
3. 🟥 Truncation (M4)
4. 🟥 Health as OTLP metrics
5. 🟥 FIPS TLS build (BL-0006)
6. 🟥 Packaging, CI and first release (M8)

## Member items

ADR-0006, ADR-0007 · BL-0002, BL-0006, BL-0007, BL-0019 (the demo consumer is its test collector) ·
lesson BL-0008

## Wake trigger

Already on: the shipper's first SOW is the current priority.
