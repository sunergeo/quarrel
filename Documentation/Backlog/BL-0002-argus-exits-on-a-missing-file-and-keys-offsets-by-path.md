---
id: BL-0002
title: argus exits when its file is missing and keys offsets by path, so rotation loses its place
type: Bug
status: New
horizon: now
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-12
affected: src/state.rs; src/main.rs (tail)
disposition: null
severity: Major
---

# BL-0002 — Missing file exits; offsets are keyed by path

## Summary

Known gaps by design, recorded in the M1/M2 commits: `argus tail` exits on a missing file, and
`state::State` keys offsets by path, so a rotated or renamed file resumes at the wrong offset. M3
discovery is the planned fix; `fingerprint` (`d84c729`) is its first step and is not wired in yet.

## Log

- 2026-11-12 — Captured at onboarding (GOV-CR-0024) from the M1/M2 commit notes.
