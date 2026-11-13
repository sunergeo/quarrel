# ADR-0010 — The README is the public front page, and every change keeps it current

- **Status:** **Accepted 2026-11-13.** SB's ruling.
- **Date:** 2026-11-13
- **Deciders:** SB
- **Scope:** Repo-level. What the README must say, when it must change, and how drift is caught.
- **Related:** ADR-0001 (the public GitHub mirror); ADR-0006 (claims are proven before they are
  made); the brand spec (feature claims).

## Context

The README is the first thing a GitHub visitor sees, and SB is pinning this repository as a showcase
of his workflow and process. A README that drifts from the decisions, the status or the code
undermines exactly what it is meant to demonstrate. On 2026-11-13 it had already drifted: it claimed
the shipper ships lines to an endpoint (it does not yet), and it said nothing about OTLP, platforms,
direction or how to contribute.

## Decision

1. **The README is a downstream document of everything below.** It sits in the same sync chain as
   `STATUS.md` (`governance-core` §5, §8): a change that alters what the README describes updates the
   README **in the same change**, not later.
2. **What the README must always state truthfully:**
   - Every crate in the workspace, and every planned one, with its honest status label:
     **In development**, **Planned**, or (once true) **Released vX.Y.Z**. A capability is described as
     present only after the outcome that proves it is Done (ADR-0006).
   - What quarrel is for and how it is delivered: production-grade by design, OTLP only, no bundled
     dashboards (ADR-0006, ADR-0007, ADR-0009).
   - Supported platforms and privilege model.
   - Where it is going: links to `BIG-IDEAS.md`, `ROADMAP.md`, `STATUS.md`.
   - How to contribute (ADR-0001), the licence, and how to build, test and run what exists.
   - A layout table that matches the tree.
3. **Triggers.** The README is reviewed, and updated if needed, whenever any of these happens:
   - an ADR is Accepted, amended or superseded;
   - an SOW changes status, above all to **Done** (a capability may now be claimed);
   - a crate, binary, command, environment variable or image is added, renamed or removed;
   - a release is cut, or the release model changes;
   - the brand spec's feature claims or the contribution route change.
4. **Enforced three ways:**
   - **Every SOW's Definition of Done** includes "README reflects this outcome" (the repo's SOW
     template carries the checkbox).
   - **Every rollup** (the promote procedure) checks the README against the change being promoted,
     and runs `scripts/check-readme.sh`; a failure stops the promotion.
   - **`scripts/check-readme.sh`** catches mechanical drift: every workspace member and every
     planned crate named in the README's crate table with a status label, every relative link
     resolving, and no capability verb in an unreleased crate's row that the status forbids. It runs
     in CI once CI exists (shipping SOW OQ2).
5. **What the check cannot catch** (a claim that is true in words but stale in substance) is the
   rollup review's job; the script is the floor, not the judgement.

## Consequences

- Promotions take a minute longer; the README never needs a "catch-up" pass.
- The README's opening sections are for visitors; the developer sections follow and stay accurate
  too.
- If quarrel's process is later canonised for other public Sunergeo repositories, this ADR is the
  working example.
