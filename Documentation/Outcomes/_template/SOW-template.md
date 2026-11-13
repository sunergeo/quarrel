# SOW: <Outcome stated as an observable behavior>

**Status:** Planned
**Created:** YYYY-MM-DD
**Last updated:** YYYY-MM-DD
**Owner:** <owner>
**Big idea:** <BI-NN — the strategic Big Idea this outcome advances, or `—` if none. Link by stable id, not a path.>

> The title MUST name an outcome, not an implementation. Use behavior-verbs (`deliver`, `ensure`,
> `enable`, `guarantee`, `within`, `reliably`, `you can now`), not code-verbs (`migrate`,
> `refactor`, `rewrite`, `consolidate`, `unify`). If the title starts with a code-verb, reframe
> before continuing. Before creating this SOW, search `Outcomes/` (active and `_archived/`) for one
> that already covers — or could be expanded to cover — this outcome, and expand it instead
> (`governance-core` §2 rule 3).
>
> **Status** is exactly one of: `Planned` · `In Architecture` · `In Engineering` · `In Review` ·
> `Done` · `Paused` · `Cancelled` · `Superseded by <slug>` (`governance-core` §3). Update it at the
> transition moment and log the transition below.
>
> **Labels** (canon `standards/terminology.md`): `Sc1` scenario · `OQ1` open question · `D1`
> decision · `NG1` out-of-scope item · `R1` risk. This outcome is their namespace — downstream
> Architecture / Engineering / Review docs **continue** these sequences, they never restart at 1.
> Never renumber; strike through and mark instead. Cite another repo's records in your org's id
> form (`<repo> BL-NNNN`, or `<PREFIX>-BL-NNNN`).

---

## 1. Outcome

One paragraph. What does the user (or the system, on the user's behalf) do differently because this
SOW shipped? Write it as an observable behavior, from the perspective of whoever observes it, and
concretely enough that someone could run it against staging or production and watch it pass or
fail. No component names, no implementation mechanics.

## 2. Why this matters

A few sentences on the user need, the business value, or the technical debt this addresses. This is
the section that justifies the work to a future reader who wasn't in the room.

## 3. Scope

### In scope

- Components: <the workspaces / packages / deployable components this SOW touches>
- Concretely: <bullet list of what's covered>

### Out of scope (explicit)

- **NG1 — <adjacent thing deliberately deferred>.** Disposition: <→ BL-NNNN / later SOW / won't
  do>. Naming them prevents scope creep mid-SOW.
- **NG2 — …** <If a component is not in scope, name it here so the deferral is visible.>

## 4. Acceptance Criteria (Definition of Done)

The DoD is a **set of runnable scenarios against the running product** (staging/production). Each
criterion is observable pass/fail — not "PRs merged," not "phase complete." Shape: "do or trigger
X; observe Y (within Z)."

- [ ] **Sc1 — <short name>.** <action or trigger>. Expected: <observable outcome, and timing where it matters>. Test path: <how to run — e2e spec, script, manual repro steps, log/metric to watch>.
- [ ] **Sc2 — …**
- [ ] **README reflects this outcome** (ADR-0010): what it can now claim, statuses, commands and
  layout; `scripts/check-readme.sh` passes.
- [ ] (For multi-component SOWs) Per-component status:
  - `<component>`: [ ] Pass [ ] Fail
  - `<component>`: [ ] Pass [ ] Fail [ ] N/A — out of scope

## 5. Architectural notes

Brief pointers to constraints this SOW must respect — the contracts it conforms to (and where they
are the source of truth), component boundaries, design-system or accessibility rules, environment
topology, platform standards. Detailed architecture lands in `./Architecture/` when work starts;
this section just flags the constraints up front.

Decisions already locked when the SOW is written go here as a table
(`| D1 | <decision> | <why / ruling> |`); later decisions continue the sequence in the Architecture
and Engineering docs.

## 6. Open Questions

This is the outcome's **OQ register**: an open question raised in any downstream doc is listed here
too, with a pointer.

- **OQ1 — <question>.** <What it blocks; which increment needs the answer.> Resolve in place:
  `~~**OQ1 — …**~~ **Resolved YYYY-MM-DD → D3**` (or `Withdrawn` / `Transferred → BL-NNNN`).
- Also the landing spot for "SOW update required" placeholders when downstream propagation can't
  complete in the same session.

## 7. Release notes draft

> Write for users, not engineers. No component names, no implementation mechanics.
> ✅ "You can now…" / "Improved: …" / "Fixed: …"   ❌ "Migrated X to Y" / "Refactored Z"

The repo whose `release.notes_path` binds the product's user-facing notes store owns the published
entry; this is the user-oriented line for when the outcome ships:

- <One or two user-facing lines describing what changed from the user's perspective.>

## 8. Feature flag

- Flag name: `<flag_name>` (scoped tightly to this outcome; registered in `.canon-flags`)
- Default state: off
- Promotion criteria: DoD scenarios pass on staging.

(For an outcome that is not flagged — because it genuinely can't be, or by an org or product
ruling — write "No flag — <reason>". The deviation is recorded, not silent.)

## 9. Lineage / Source Documents

- Governance: the repo's `CLAUDE.md`
- Contracts (source of truth): <paths>
- Backlog item(s): <BL-NNNN, if promoted from the backlog>
- Related SOWs (predecessors, peers, or the successor if `Superseded by`): <paths to `../<other-slug>/SOW-<other-slug>.md`>
- Related ADRs: <paths to `../../adr/` entries this depends on>

---

## Revisions

Material scope or acceptance-criteria changes get recorded here with date and reason. Do not
silently rewrite the body; preserve prior text inline (strikethrough/superseded) or as a Revisions
entry. A SOW that absorbs another's scope (expand-before-fork, or as the successor of a
`Superseded by` SOW) records it here, naming where each piece came from.

- YYYY-MM-DD — <What changed and why.>

## Phase Transitions

One line per transition. Date, prior → new status, path to the doc that triggered the move. Every
entry updates `Documentation/STATUS.md` in the same session.

- YYYY-MM-DD — Status: Planned. SOW created.
