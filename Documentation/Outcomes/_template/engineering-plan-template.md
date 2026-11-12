# Engineering plan: <slug> — <component>

> **Status:** Draft | Active | Done
> **Created:** YYYY-MM-DD
> **Last updated:** YYYY-MM-DD

> Copy to `Outcomes/<slug>/Engineering/<slug>-<component>-engineering-plan.md` and delete the
> guidance blockquotes.
>
> **Labels** (canon `standards/terminology.md`): increments are `E1, E2, …` on **every** tier (never
> `F#`, `P#`, `Phase N`). This plan **continues** the outcome's `D#`, `OQ#`, `R#` and `NG#` sequences
> from the SOW and Architecture docs — if the SOW stops at `OQ4`, the first new question here is
> `OQ5`. Insert between two increments with a letter (`E2a`), never a decimal. Never renumber. Cite
> the paired repo's plan as `<repo> <slug> E4`, and qualify labels in code comments and test names
> (`BL-NNNN E3`).

## Lineage / Source Documents

- **SOW:** `../SOW-<slug>.md`
- **Backlog item:** `BL-NNNN` (if promoted from the backlog)
- **Architecture:** `../Architecture/<doc>.md`
- **Pairs with (other repo):** `<repo> Outcomes/<slug>/Engineering/<doc>.md` — cite its increments as `<repo> <slug> E#`
- **Contracts:** <paths>

## Decisions

Decisions this plan locks, continuing the outcome's sequence. Operator rulings are decisions; mark
them.

| ID | Decision | Why / source |
|---|---|---|
| D5 | <decision> | <reason; "<who> ruling YYYY-MM-DD"> |

## Increments

One row per shippable slice, in build order. Each names the acceptance scenarios it moves.

| ID | Increment | Covers | Depends on | Status |
|---|---|---|---|---|
| E1 | <what ships> | Sc1, Sc2 | — | Planned |
| E2 | <what ships> | Sc3 | E1, <repo> BL-NNNN | Planned |

### E1 — <title>

<What changes, where, and how you know it works. Done when: <observable check>.>

### E2 — <title>

…

## Test strategy

How the increments are proven, mapped to the SOW's scenarios. Enumerate cases as `T1…` only if a
checklist needs to cite them.

| Scenario | Proven by |
|---|---|
| Sc1 | <spec / suite / manual repro> |

## Risks

- **R1 — <risk>.** Mitigation: <…>. Rollback: <…>.

## Open Questions

Continue the outcome's sequence and add each one to the SOW §6 register with a pointer here.

- **OQ5 — <question>.** Blocks: <E#>.

## Out of scope (explicit)

- **NG3 — <deferred item>.** Disposition: <→ BL-NNNN / later increment / won't do>.
