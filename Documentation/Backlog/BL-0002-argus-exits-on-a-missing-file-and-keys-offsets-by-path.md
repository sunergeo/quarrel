---
id: BL-0002
title: The shipper exits when its file is missing and keys offsets by path, so rotation loses its place
type: Bug
status: New
horizon: now
big_idea: BI-02
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-14
affected: src/state.rs; src/main.rs (tail)
disposition: null
severity: Major
---

# BL-0002 — Missing file exits; offsets are keyed by path

## Summary

Known gaps by design, recorded in the M1/M2 commits: `argus tail` (now `quarrel-shipper tail`) exits on a missing file, and
`state::State` keys offsets by path, so a rotated or renamed file resumes at the wrong offset. M3
discovery is the planned fix; `fingerprint` (`d84c729`) is its first step and is not wired in yet.

## Discovery requirements for M3 (from the shipping architecture, R4)

When globs and discovery arrive, they must also:

1. **Cap and report:** respect `max_files` (shipping architecture D17); for globs, track the newest N
   by modification time and say so loudly.
2. **No backfill flood:** files that already exist when the shipper first sees them start at their
   end by default; files that appear later start at the beginning; an age cutoff (`ignore_older_than`,
   e.g. 24 h) skips stale files. A deliberate backfill is an explicit opt-in.
3. **Exclusions:** always exclude the shipper's own state and quarantine folder (a feedback loop
   otherwise); exclude compressed files unless enabled; skip files that look binary; support
   user exclude patterns.
4. **Cheap polling:** check only size and modification time each tick and read changed files; re-run
   globs far less often (e.g. every 10 s); limit recursion depth for `**`.
5. **State clean-up:** already built in the shipping SOW (architecture D21: expiry and cap); M3 moves
   the state key from path to fingerprint.
6. **Fairness:** keep D16's round-robin, per-file share of each batch.

## Log

- 2026-11-12 — Captured at onboarding (GOV-CR-0024) from the M1/M2 commit notes.
- 2026-11-14 — Discovery requirements added (rogue glob patterns; shipping architecture R4).
