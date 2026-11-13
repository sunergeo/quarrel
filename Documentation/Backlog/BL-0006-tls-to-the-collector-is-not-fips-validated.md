---
id: BL-0006
title: TLS to the collector is not FIPS-validated, so quarrel cannot yet serve regulated environments that require it
type: Standard-gap
status: Triaged
horizon: next
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0006 §3; ADR-0007 §7; crates/quarrel-shipper (HTTP client, TLS provider)
disposition: null
---

# BL-0006 — TLS to the collector is not FIPS-validated

## Summary

Regulated environments often require FIPS-validated cryptography for any traffic that may carry
sensitive data, and log lines can carry it. SB, 2026-11-13: plain TLS first, FIPS later. This item
keeps the gap visible until it is closed.

## Likely shape

rustls with the `aws-lc-rs` FIPS provider behind a build feature, so an operator who needs it
builds with the feature on. It adds a C/CMake toolchain (and Go, for the FIPS module build) to those
builds, which must still build offline from vendored sources (ADR-0006 §3, supply chain).

## Must be closed before

quarrel is offered for a deployment that requires FIPS-validated transport.

## Log

- 2026-11-13 — Captured with ADR-0006/ADR-0007.
