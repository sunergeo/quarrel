# ADR-0002 — quarrel is one toolkit: a shared core with a shipper and a probe

- **Status:** **Accepted 2026-11-12.** The workspace and the shipper rename are built (2026-11-12,
  BL-0005); `quarrel-core` and `quarrel-ping` (formerly `quarrel-probe`) are not built yet (see Consequences).
- **Date:** 2026-11-12
- **Amended:** 2026-11-13 by `ADR-0006` (purpose: production-grade tooling; Context, third
  paragraph); 2026-11-13 by `ADR-0008` (the network tool is `quarrel-ping`; §1, §4, §5)
- **Deciders:** SB
- **Scope:** Repo-level. What quarrel is, how its code is divided, and what the parts are called.
- **Related:** ADR-0001 (publication and license); ADR-0003 (probe portability); ADR-0004 (probe
  measurement); ADR-0005 (event model and outputs).

## Context

quarrel today holds one crate, `argus`, a per-host log shipper built milestone by milestone
(M0–M2 shipped, M3 in progress). The plan is to add an active network probe: a tool that measures
latency, jitter, packet loss and per-hop paths from the machine it runs on.

Both tools run on the same hosts, need the same plumbing (identity labels, timestamps, a durable
buffer, outputs, crash-safe state) and answer the same operator question from two sides: what the
software *said* (logs) and what the network *did* (measurements). Kept as two repos, that plumbing
would be written twice and the two streams would drift apart.

~~The project is also deliberately a public learning project: low-level networking, file I/O and
portable systems programming in Rust, built to production standards, with the reasoning written
down. Many tools like it already exist; the learning and the demonstration of it are the point.~~

**⚠ Amended 2026-11-13 by `ADR-0006`.** quarrel is a production-grade suite of observability tools.
Learning Rust and low-level protocols, and the public portfolio, are
by-products, not the point. The toolkit decision below is unchanged.

The name: a *quarrel* is a crossbow bolt. Send a small projectile toward a target and observe what
happens.

## Decision

1. **One repository, one Cargo workspace, two binaries over a shared core.**
   - **`quarrel-core`** (library) — the event model, identity labels, timestamps, outputs, the
     durable disk buffer, configuration and crash-safe state.
   - **`quarrel-shipper`** (binary) — tails log files and forwards them without losing a line. It is
     today's `argus` crate, renamed.
   - ~~**`quarrel-probe`** (binary) — sends its own probes and reports what the network did.~~
     **⚠ Amended 2026-11-13 by `ADR-0008`:** **`quarrel-ping`** (binary), PingPlotter-style network
     observability for a defined system: segments, routing, latency and bottlenecks.
   - Supporting libraries are split out only when a boundary earns it. The first planned one is
     the probe's I/O-free packet code (ADR-0003 §3).
2. **The shipper keeps its invariant:** never save a file offset past what the destination has
   acknowledged. A duplicate is harmless; a skipped line is the only real failure.
3. **The probe can write events straight into the shared core**, without going through a file
   the shipper then tails.
4. **Names:** the project and the workspace are `quarrel`, and the crates carry the
   `quarrel-` prefix. The names `quarrel`, `quarrel-shipper` and `quarrel-probe` were unclaimed on
   crates.io on 2026-11-12. Publishing to crates.io is a separate decision, not taken here.
   **⚠ Amended 2026-11-13 by `ADR-0008`:** the network tool is `quarrel-ping`; its crates.io
   availability is to be confirmed.
5. ~~**The UI is not a goal.** Both binaries are command-line tools. A terminal UI for the probe may
   come later; a desktop or web front end is out of scope.~~
   **⚠ Amended 2026-11-13 by `ADR-0008` §4:** for observability, quarrel only emits OTLP and
   consumers build their own dashboards. quarrel-ping will gain a standalone TUI mode (planned), and
   native Windows/macOS clients are a possible enhancement. A web front end remains out of scope.

## Consequences

- **Moving `argus` into the workspace and renaming it to `quarrel-shipper` is a code change** with
  its own milestone. Until then `Cargo.toml` and the binary are still named `argus`, and the
  shipper's M-numbered roadmap continues unchanged. *(Built 2026-11-12, BL-0005: root workspace,
  `crates/quarrel-shipper`, binary `quarrel-shipper`, env `QUARREL_ENV`. The M-numbered roadmap
  continues unchanged.)*
- **The probe gets its own milestone track** (P1–P6, see `ROADMAP.md`), separate from the shipper's
  M0–M8.
- **Shared code is shared on purpose.** Changes to `quarrel-core` must keep both binaries' tests
  green.
