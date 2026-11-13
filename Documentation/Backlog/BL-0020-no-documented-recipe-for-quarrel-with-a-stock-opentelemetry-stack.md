---
id: BL-0020
title: No documented recipe shows quarrel feeding a stock OpenTelemetry Collector and open-source dashboards
type: Doc-debt
status: Triaged
horizon: next
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0009 §3; examples (planned)
disposition: null
---

# BL-0020 — A stock-stack recipe

## Summary

ADR-0009 §3: an example `docker compose` setup with an OpenTelemetry Collector, open-source log and
metric backends and provisioned Grafana dashboards, fed by quarrel's tools. It proves
interoperability and is the shipping SOW's "once against a stock collector" run.

## To decide when taken up

- Which backends (for example Loki for logs, Prometheus or Mimir for metrics).
- Licences of each pulled image, listed in the recipe.
- Dashboards as provisioned JSON in the repo.

## Log

- 2026-11-13 — Captured with ADR-0009.
