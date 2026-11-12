---
id: <TRACK>-BL-NNNN        # immutable, matches filename stem
title: <one-line title>    # plain text, no markdown
type: Standard-gap         # Standard-gap | Skill-gap | Enforcement-gap | Process-idea | Doc-debt | Bug
status: New                # New | Triaged | Active | Implemented | Closed
horizon: someday           # now | next | someday   (someday = default/unspecified; set at triage)
big_idea: null             # BI-NN this serves, or null
reporter:
opened: YYYY-MM-DD
updated: YYYY-MM-DD        # last material change
affected: null             # e.g. standards/git-branch-roles.md; governance-core/SKILL.md §11; enforcement/hooks/update
disposition: null          # null until routed; then link the change record / other backlog / duplicate
# Optional — use for a Bug, or anything found while soaking a release candidate:
# severity: Major          # Blocker | Major | Minor
# found_in: vX.Y.Z-rcN     # the release or candidate where it was found
---

# <TRACK>-BL-NNNN — <one-line title>

> Every backlog item is a file. The frontmatter above is the machine-read record; `BACKLOG.md` is a
> **generated** index over it (`canon-index`) — don't hand-edit the index. Copy this file to
> `<TRACK>-BL-NNNN-<slug>.md` with the next id (the index prints it), fill in the frontmatter +
> body, and delete these guidance blockquotes. `<TRACK>` is `GOV` on an org track and `CANON` on
> canon's own track; a product repo uses the same shape with its own id form
> (`standards/terminology.md` §5). `horizon` and `big_idea` are set at triage; a fresh capture is
> just `status: New` / `horizon: someday`.

## Summary

<One or two sentences. What is wrong or missing, in plain terms?>

## Detail

<Context and motivation. Quote the conflicting/missing passages with file + section so the change
is unambiguous. For an **Enforcement-gap**, use the structure below.>

- **Where the rule is authored:** <file + section — the source of truth>
- **Where it's inconsistent / missing:** <the other file(s) that disagree or omit it>
- **Observed impact:** <how it bit, ideally with a concrete example>

> Number anything a later line or the change record will cite — `OQ1` open question, `D1`
> decision/ruling — per `standards/terminology.md`. Delete this line.

## Triage notes

- YYYY-MM-DD — <decision, who made it, why; the disposition + horizon chosen>

## Lineage (once promoted or routed)

- Promoted to: `../Changes/<TRACK>-CR-NNNN-<slug>.md`
- Or routed to: the governed repo's `Documentation/BACKLOG.md` (product-scoped), or the canon track
  as `CANON-BL-NNNN` (an L0 proposal)
- Or closed: <won't-fix reason / duplicate of <TRACK>-BL-NNNN>

## Log

> Append-only, one short dated line per material update. This is where per-item history lives —
> never in the `BACKLOG.md` index.

- YYYY-MM-DD — captured.
