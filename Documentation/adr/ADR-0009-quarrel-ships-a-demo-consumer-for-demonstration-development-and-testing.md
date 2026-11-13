# ADR-0009 — quarrel ships a demo consumer for demonstration, development and testing

- **Status:** **Accepted 2026-11-13.** SB's ruling on direction. Nothing is built yet.
- **Date:** 2026-11-13
- **Deciders:** SB
- **Scope:** Repo-level. A consumer that lives in this repo: what it is for, what it must never
  become, how it is built and packaged.
- **Amends:** ADR-0002 §5 as amended by ADR-0008 ("a web front end remains out of scope"): the tools
  still have no web UI; the demo consumer has one.
- **Related:** ADR-0005 (open formats); ADR-0007 (the shipper's OTLP contract); ADR-0008 §4
  (observability is OTLP only; dashboards are the consumer's); the shipping SOW (OQ1); BL-0007.

## Context

quarrel's tools only emit OTLP, and dashboards are each consumer's to build (ADR-0008 §4). That
leaves a newcomer with nothing to look at, and leaves development and the shipping SOW without a
receiver they control. SB, 2026-11-13: quarrel will include a consumer that runs as a Docker image,
publishes an OTLP endpoint both tools can send to, and serves a web dashboard that demonstrates how
to use them. For demo, development and test only. SB chose both a single-image consumer of our own
and a documented recipe for a stock stack, and React for the dashboard ("so I can gain some
experience there").

## Decision

1. **`quarrel-demo`: one Docker image, our own code.** A workspace member (`crates/quarrel-demo`)
   containing:
   - **An OTLP/HTTP receiver** (`/v1/logs`, `/v1/metrics`; protobuf and gzip, as ADR-0007 sends)
     that both quarrel-shipper and quarrel-ping can point at.
   - **A small store** with short, bounded retention (in memory or SQLite), deduping shipper lines
     on ADR-0007's key, as a real consumer must.
   - **A web dashboard** in React, built to static files at image-build time and served by the same
     process, with a JSON API behind it. It shows: shipped lines with a live tail, per-file lag,
     gaps and health; quarrel-ping's per-hop latency and loss over time, segments and their owners,
     route changes and the attribution verdict.
2. **It is also the test collector** (shipping SOW OQ1 → D6). A test mode can be told, through a
   small control API, which response to return next (every case in ADR-0007 §4), and exposes what it
   has received so tests can assert "every line in the file arrived, by dedupe key". The SOW's
   scenarios run against it in CI; one run also goes against a stock OpenTelemetry Collector (§3).
3. **A stock-stack recipe, documented, not built by us.** An example `docker compose` setup showing
   quarrel feeding an OpenTelemetry Collector and open-source backends with provisioned Grafana
   dashboards. It proves interoperability and shows the "consumers build their own dashboards" path
   with industry tools. Third-party images are pulled, not bundled; their licences are listed.
4. **Demo, development and test only, and it says so.**
   - Binds to localhost by default, has no authentication, keeps little data, and its UI and docs
     state "not for production".
   - Nothing in quarrel-shipper, quarrel-ping or quarrel-core depends on it; removing it breaks no
     tool.
   - It contains no product logic the tools need. Anything it computes for display (for example,
     segment attribution) comes from the tools' own telemetry, so the demo never becomes the only
     place a feature exists.
   - It stays vendor-neutral: it is an example consumer, not a product backend.
5. **Supply chain applies to it too, scaled to its role.** Rust dependencies go through the same
   `cargo deny` / `cargo audit` checks; the web build's npm dependencies get a licence and advisory
   check, are pinned with a lockfile, and never enter the tools' images.
6. **The tools have no web UI.** Their user interfaces stay as ADR-0008 §4 sets them: OTLP for
   observability, a future TUI, possible native clients.

## Consequences

- The shipping SOW's test collector is the demo's test mode (D6), so the demo's receiver and control
  API become a dependency of that SOW's DoD, ahead of the dashboard.
- BL-0007 (the documented output contract) gains a living example: the demo's receiver is the
  reference mapping from ADR-0007 records to a generic line store.
- The image build gains a Node stage (React build) before the Rust stage; the runtime image stays
  minimal.
