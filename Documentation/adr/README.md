# Architecture Decision Records — quarrel

Repo-level decisions that outlive any single SOW (`governance-core` §9). Outcome-specific decisions
live in that outcome's `Outcomes/<slug>/Architecture/` instead. Any change here updates
`../STATUS.md` in the same session.

**Numbering:** `ADR-NNNN-<decision>.md`, four-digit, sequential, immutable. **Status:** Proposed ·
Accepted · Superseded by ADR-NNNN · Deprecated. An amendment follows `governance-core` §9.1
(state it, record it in the amended header, **and** mark the amended clause inline).

## Index

| ID | Title | Status |
|---|---|---|
| [ADR-0001](./ADR-0001-quarrel-is-published-as-a-public-github-mirror-of-gitolite.md) | quarrel is published as a public GitHub mirror of gitolite, dual-licensed MIT OR Apache-2.0 | Accepted |
| [ADR-0002](./ADR-0002-quarrel-is-one-toolkit-a-shared-core-with-a-shipper-and-a-probe.md) | quarrel is one toolkit: a shared core with a shipper and a probe (amended by ADR-0006, ADR-0008) | Accepted |
| [ADR-0003](./ADR-0003-quarrel-probe-is-portable-by-construction.md) | quarrel-ping (was quarrel-probe) is portable by construction: macOS first, Windows and Linux supported | Accepted |
| [ADR-0004](./ADR-0004-quarrel-probe-measures-paths-the-way-mtr-does.md) | quarrel-ping (was quarrel-probe) measures paths the way MTR does, with timing it can defend | Proposed |
| [ADR-0005](./ADR-0005-quarrel-emits-one-vendor-neutral-timestamped-event-stream.md) | quarrel emits one vendor-neutral, timestamped event stream | Accepted |
| [ADR-0006](./ADR-0006-quarrel-is-production-grade-observability-tooling.md) | quarrel is production-grade observability tooling | Accepted |
| [ADR-0007](./ADR-0007-quarrel-shipper-delivers-over-otlp-http-and-advances-only-on-acknowledgement.md) | quarrel-shipper delivers over OTLP/HTTP and advances only on acknowledgement | Proposed |
| [ADR-0008](./ADR-0008-the-network-tool-is-quarrel-ping-and-it-observes-network-traffic-within-a-defined-system.md) | The network tool is quarrel-ping: observability into what network traffic actually does within a defined system | Accepted |
| [ADR-0009](./ADR-0009-quarrel-ships-a-demo-consumer-for-demonstration-development-and-testing.md) | quarrel ships a demo consumer for demonstration, development and testing | Accepted |
