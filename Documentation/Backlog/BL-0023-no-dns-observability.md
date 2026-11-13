---
id: BL-0023
title: "Candidate tool: DNS observability (resolution time per resolver, answer changes, failures, DNSSEC)"
type: Process-idea
status: New
horizon: someday
big_idea: BI-01
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: a new quarrel tool, or a quarrel-ping mode (to be decided); quarrel-core
disposition: null
---

# BL-0023 — Candidate tool: DNS observability

## Idea

Measure name resolution for the defined system's endpoints, per resolver: resolution time over time,
answers and when they change, failures and timeouts, TTL behaviour, DNSSEC validation. Ship as OTLP
with the same identity labels.

## Why it fits quarrel

- DNS is a step on every path that quarrel-ping does not see; "the resolver was slow" and "the answer
  changed" are classic hidden causes, and an answer change often explains a route change (BI-01).
- No privileges needed; a small, self-contained tool on quarrel-core.

## Learning

The DNS wire format (a small binary protocol; the same pure-codec discipline as ICMP, ADR-0003 §3),
UDP retry and timeout design, caching semantics.

## To decide when taken up

A separate tool, or a mode of quarrel-ping that resolves its own targets and reports it.

## Log

- 2026-11-13 — Captured from the expansion-candidates discussion (candidate 2).
