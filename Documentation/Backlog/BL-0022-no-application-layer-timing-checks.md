---
id: BL-0022
title: "Candidate tool: application-layer timing checks (DNS, connect, TLS, first byte, transfer) to tell network from service"
type: Process-idea
status: New
horizon: someday
big_idea: BI-03
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: a new quarrel tool (name to be decided); quarrel-core
disposition: null
---

# BL-0022 — Candidate tool: application-layer timing checks

## Idea

For each declared endpoint, measure a request continuously and break its time into phases: name
resolution, TCP connect, TLS handshake, time to first byte, transfer. Also report status codes and
certificate expiry. Ship it as OTLP with the same identity labels quarrel-ping uses, so a slow TLS
handshake on a clean path reads as "the service", and a step at a carrier segment reads as "the
network".

## Why it fits quarrel

- Completes quarrel-ping's picture (BI-03): network, resolver, or service.
- Black-box checks from outside the app hosts are a common operator need.
- No privileges needed; reuses quarrel-core's event model, labels and outputs.

## Learning

TLS handshake phases, X.509 chains, HTTP/1.1 versus HTTP/2 connection reuse, timing breakdowns as
distributions (the `latency_stats` lesson applies directly).

## Before it starts

quarrel-core exists; quarrel-ping P2 is done (BI-03 wake trigger). Name the tool then.

## Log

- 2026-11-13 — Captured from the expansion-candidates discussion (candidate 1).
