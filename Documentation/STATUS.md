# quarrel — status

The at-a-glance view of this repo's outcomes (canon `governance-core` §0). Each live SOW under
`Outcomes/<slug>/` gets one row here, kept in step with the SOW's own `Status:` line.

| Outcome | Status | Updated |
|---|---|---|
| — | — | — |

No SOWs yet. Onboarded 2026-11-12 (GOV-CR-0024) at `scope: roster`, `releaseModel: trunk-only`.
Shipped before onboarding: argus M0–M2 (`scan`, `tail`, persisted offsets) and M3 step 1
(`fingerprint`). Not deployed. Open signal: `BACKLOG.md`; intent: `ROADMAP.md`.

Published: public mirror at `github.com/sunergeo/quarrel` (ADR-0001, Accepted; `master`
`1e08c94` on both), MIT OR Apache-2.0. gitolite (`git:quarrel`) is the system of record.

Direction (2026-11-12): quarrel becomes one toolkit, with a shared core, the shipper and a network
probe (ADR-0002). The workspace exists and the shipper is in it as `crates/quarrel-shipper`
(formerly `argus`; BL-0005); `quarrel-core` and `quarrel-probe` are not built yet. The probe is portable by construction (ADR-0003, Accepted)
and emits one vendor-neutral event stream (ADR-0005, Accepted). Its measurement model is ADR-0004
(Proposed). The probe is not built yet; its I/O model is open (BL-0003).

| ADR | Status |
|---|---|
| ADR-0001 | Accepted |
| ADR-0002 | Accepted |
| ADR-0003 | Accepted |
| ADR-0004 | Proposed |
| ADR-0005 | Accepted |
