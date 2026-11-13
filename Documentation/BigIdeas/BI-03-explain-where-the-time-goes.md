---
id: BI-03
title: Explain where the time goes
state: sleeping
opened: 2026-11-13
updated: 2026-11-13
---

# BI-03 — Explain where the time goes

**North star.** When a request to a service is slow, an operator can see where the time went:
name resolution, the network path, the connection, the TLS handshake, or the service itself. It
answers "is it the network or the service?" by putting application-level timing beside
quarrel-ping's per-hop view.

**Done means.** A quarrel tool measures declared endpoints continuously with a per-phase timing
breakdown (DNS, connect, TLS, first byte, transfer) and certificate expiry, ships it as OTLP with the
same identity labels as quarrel-ping, so the two can be read together.

## Outcome spine

1. 🟥 Application-layer timing checks (BL-0022)
2. 🟥 Correlate with quarrel-ping paths for the same endpoints

## Member items

BL-0022 · related: BL-0023 (DNS, under BI-01)

## Wake trigger

quarrel-core exists (ADR-0002) and quarrel-ping P2 is done, so this tool is a thin layer on shared
plumbing rather than a parallel stack.
