# <Topic> — <N>-pass review

> **Pass:** <N> (prior: `<topic>-<N-1>-pass-review.md` | none)
> **Date:** YYYY-MM-DD
> **Verdict:** PASS | CHANGES_REQUESTED | FAIL

> Copy to `Outcomes/<slug>/Review and Remediation/<topic>-<N>-pass-review.md` (or the
> `-security-` / `-perf-` / `-a11y-` / `-ux-` / `-data-model-` / `-<component>-` variant) and delete
> the guidance blockquotes.
>
> **Labels** (canon `standards/terminology.md`): findings are `F1, F2, …`, numbered **per review
> document**, with severity in a column (`Blocker · Major · Minor`) — never in the letter (no
> `C1`/`H1`/`M1`/`L1`). Cite a finding from elsewhere with its document:
> `<topic>-<N>-pass-review F3`. A remediation plan's items are increments (`E#`, continuing the
> outcome's sequence), each naming the finding it answers.

## Lineage / Source Documents

- **SOW:** `../SOW-<slug>.md`
- **Reviewed:** <Architecture / Engineering docs, and the code range or branch>
- **Prior pass:** <path, or none>
- **Contracts:** <paths>

## Findings

| ID | Severity | Finding | Where | Fails |
|---|---|---|---|---|
| F1 | Blocker | <what is wrong> | `<path>:<line>` | Sc2 / D4 / <contract §> |
| F2 | Minor | … | … | … |

### F1 — <title>

<Evidence, why it matters, the fix you'd expect.>

## Carried from the prior pass

| Prior finding | Status now |
|---|---|
| `<topic>-<N-1>-pass-review F4` | Fixed / Still open / Won't fix (reason) |

## Open Questions

Continue the outcome's `OQ#` sequence and add each to the SOW §6 register.

- **OQ7 — <question>.**
