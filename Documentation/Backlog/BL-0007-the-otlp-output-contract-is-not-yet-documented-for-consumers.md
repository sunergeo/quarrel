---
id: BL-0007
title: quarrel-shipper's OTLP output contract is not yet documented for consumers who need to build a receiver or adapter
type: Doc-debt
status: Triaged
horizon: next
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0005 §5; ADR-0007; Documentation (output contract)
disposition: null
---

# BL-0007 — Document the OTLP output contract for consumers

## Summary

ADR-0007 says quarrel speaks only OTLP and that a consumer with a different ingest protocol adapts on
its own side. That only works if the contract is written down where a consumer can build against
it: ADR-0005 §5 requires the output formats to be versioned and documented in the repo.

## What the document covers

1. The record mapping (ADR-0007 §2): resource and record attributes, their types, and which are
   always present.
2. The dedupe key, and why delivery is at-least-once.
3. What quarrel treats as an acknowledgement, and what it does with every other response (ADR-0007
   §3–§4), so a receiver knows how to answer.
4. Gap records and health metrics (ADR-0007 §5, §8).
5. A worked example: one batch as protobuf-decoded JSON, and how a receiver would map it to a
   generic line store (`host`, `file`, `fingerprint`, `offset`, `read_at`, `line`).
6. The contract's version and its compatibility rules.

## Log

- 2026-11-13 — Captured.
