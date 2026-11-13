# quarrel — status

The at-a-glance view of this repo's outcomes (canon `governance-core` §0). Each live SOW under
`Outcomes/<slug>/` gets one row here, kept in step with the SOW's own `Status:` line.

| Outcome | Status | Updated |
|---|---|---|
| [Ensure every complete log line reaches an OTLP collector at least once](./Outcomes/ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once/SOW-ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once.md) | Planned | 2026-11-13 |

Purpose (ADR-0006, 2026-11-13): production-grade observability tooling, vendor-neutral; learning and
the portfolio are by-products. The shipper delivers over OTLP/HTTP (ADR-0007, Proposed); consumers
with other ingest protocols adapt on their side, against the documented contract (BL-0007). FIPS TLS
is a tracked gap (BL-0006).

Onboarded 2026-11-12 (GOV-CR-0024) at `scope: roster`, `releaseModel: trunk-only`.
Shipped before onboarding: argus M0–M2 (`scan`, `tail`, persisted offsets) and M3 step 1
(`fingerprint`). Not deployed. Open signal: `BACKLOG.md`; intent: `ROADMAP.md`.

Published: public mirror at `github.com/sunergeo/quarrel` (ADR-0001, Accepted; pushed after
gitolite on every promotion), MIT OR Apache-2.0. gitolite (`git:quarrel`) is the system of record.

Direction (2026-11-12): quarrel becomes one toolkit, with a shared core, the shipper and a network
probe (ADR-0002). The workspace exists and the shipper is in it as `crates/quarrel-shipper`
(formerly `argus`; BL-0005); `quarrel-core` and `quarrel-ping` (the network tool, ADR-0008) are not built yet. The probe is portable by construction (ADR-0003, Accepted)
and emits one vendor-neutral event stream (ADR-0005, Accepted). Its measurement model is ADR-0004
(Proposed). The probe is not built yet; its I/O model is open (BL-0003).

| ADR | Status |
|---|---|
| ADR-0001 | Accepted |
| ADR-0002 | Accepted |
| ADR-0003 | Accepted |
| ADR-0004 | Proposed |
| ADR-0005 | Accepted |
| ADR-0006 | Accepted |
| ADR-0007 | Proposed |
| ADR-0008 | Accepted |
