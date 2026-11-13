---
id: BL-0016
title: Choose quarrel-ping's network-ownership datasets (prefix to AS, AS to organisation, exchange points) and check their licences
type: Standard-gap
status: Triaged
horizon: next
big_idea: BI-01
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0008 §3, §5; quarrel-ping (P3)
disposition: null
---

# BL-0016 — Network-ownership datasets and their licences

## Summary

ADR-0008 §5 labels every hop with the network that owns it, offline by default from local data
files, with online lookups opt-in. This item picks the sources, checks each licence, and defines
the file formats and update path. Needed before P3's attribution output.

## To decide

1. **Prefix → origin AS.** Candidates to evaluate: tables derived from public BGP collectors
   (RouteViews, RIPE RIS) such as CAIDA's prefix-to-AS files; pre-built public IP-to-ASN tables.
   Criteria: licence, update cadence, IPv6 coverage, how multi-origin prefixes are represented.
2. **AS → organisation name.** Candidates: RIR data, CAIDA AS-to-organisation, PeeringDB network
   records.
3. **Exchange-point peering ranges.** PeeringDB IX prefixes.
4. **For each:** licence terms (redistribution in an open-source repo? attribution? commercial use?),
   compatibility with OSI-only licence policies, and whether quarrel bundles it,
   documents how to fetch it, or only reads a file the operator supplies.
5. **File format** quarrel reads (compact, versioned, carries its build date and sources), and a
   `quarrel-ping` subcommand or script that builds it from the public dumps.
6. **Opt-in online sources:** which ones quarrel supports (reverse DNS, an IP-to-AS DNS service,
   RDAP), and what each sends where.

## Not acceptable

Datasets under restrictive end-user licences (no redistribution, account-gated, non-OSI-compatible
terms) are not bundled or recommended, however convenient.

## Log

- 2026-11-13 — Captured with ADR-0008 §5 (SB accepted the offline-first recommendation).
