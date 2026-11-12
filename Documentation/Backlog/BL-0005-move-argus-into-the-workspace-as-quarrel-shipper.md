---
id: BL-0005
title: Move argus into the workspace as quarrel-shipper, and rename argus everywhere it names the live code
type: Tech-debt
status: Closed
horizon: now
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-12
affected: Cargo.toml; Cargo.lock; crates/quarrel-shipper/; Dockerfile; docker-compose.yml; README.md; CLAUDE.md
disposition: "Implemented directly, ADR-0002 Consequences (no SOW: no behaviour changes except names)"
---

# BL-0005 — Move argus into the workspace as quarrel-shipper

## Summary

2026-11-12, SB: "a global rename from argus to quarrel." ADR-0002 already decided the shape, and SB
chose to build it now: a Cargo workspace at the repo root, with today's crate moved to
`crates/quarrel-shipper`.

## What changed

| Was | Now |
|---|---|
| root crate `argus` | workspace root + `crates/quarrel-shipper` (lib `quarrel_shipper`) |
| binary `argus` | `quarrel-shipper` (`--version` prints `quarrel-shipper 0.1.0`) |
| `ARGUS_ENV` | `QUARREL_ENV` (SB's choice: project-wide, the probe reads it too) |
| image / service `argus:dev` | `quarrel-shipper:dev` |
| `[profile.release]` in the crate | at the workspace root (Cargo ignores member profiles) |

## Deliberately not renamed

- **History.** Commit messages and the `argus:` subject prefix stay: `master` is protected and public.
  New shipper commits use `quarrel-shipper:`.
- **Decision and history text** that describes the past: ADR-0002's Context and Decision, BL-0001,
  this repo's onboarding record (GOV-CR-0024). They were true when written.
- **Backlog file names.** Ids and slugs are immutable (`BL-0002-argus-…`); the titles are updated.
- **Outside this repo:** the services repo's argus wiring (heartbeat ids like `argus@host1`, registry,
  watchtower docs) is the separate "Argus references removal" work there.

## Log

- 2026-11-12 — Captured and implemented the same session.
- 2026-11-12 — SB on the Mac: `cargo test --locked` green (Cargo.lock unchanged), `--version` and the
  Docker build checked. Rolled up to `master`; Closed.
