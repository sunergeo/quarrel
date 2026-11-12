---
name: governance-core
description: The universal canon governance meta-model and git/release standards, inherited by every org, product and repo that pins canon. Use this whenever working inside any product's `Documentation/` tree — creating or updating a SOW, backlog item, ADR, roadmap entry, or status dashboard; moving work between lifecycle phases; answering a status / "what's next" / backlog question about a governed product; running a lineage-grounded code review; or making a git/branch/release decision. Triggers on "SOW", "backlog / BL-", "outcome", "definition of done / DoD", "ADR", "STATUS.md", "ROADMAP", "status of <product>", "what's next on <product>", "phase transition", "archive an outcome", "duplicate SOW", "expand an existing SOW", "branch model", "release discipline", "rollup", "cut an RC", "promote to production", "release notes", "feature flag per outcome", "is this on-brand for our workflow", or any question about where a governance doc belongs or whether a workflow action is compliant. This is the framework-tier (L0) skill; product-specific repo rules live in the repo-tier skills (`governance-fe` / `governance-be`, filled in from canon's `repo-tier-fe` / `repo-tier-be` skeletons), which preload this.
---

# Governance Core — the canon outcome-centric meta-model

This skill is the **framework tier (L0)** of governance. It encodes the parts of the workflow that
are identical for **every** org, product and repo that pins canon. It is authored once, here, and
inherited by install: each org vendors a pinned canon release, and a product's repo-tier skill
(`governance-fe`, `governance-be`) preloads this skill rather than restating its rules. An org or
product may **add** to a prose rule here (an L1/L2 addendum); it may not contradict it, and loosening
anything `locked` needs a canon change record, never an org edit (`standards/layering.md`).

The model is **outcome-centric**: work is organized around observable outcomes a user
experiences, not around code changes. Status is read from a SOW's Status field, never inferred
from where a folder sits. History is preserved, never deleted. Every document cites its lineage,
and related documents are kept in sync within the same edit session.

If a request conflicts with these rules, **surface the conflict before proceeding** — propose
the compliant path rather than silently doing the non-compliant thing.

> **Altitude check.** This skill owns the *shape* of the workflow and the universal git/release
> standards. It deliberately names no org, product, app, service, shared library, or
> product-specific file — those belong to L1 (the org governance repo), L2 (the product) and the
> repo tier (`governance-fe` / `governance-be`, plus the product's codex). If you find yourself
> needing a workspace name, a host name or a wire-format contract, you've dropped a tier; consult
> that tier.

> **Paths and names.** `standards/…`, `templates/…`, `guides/…`, `enforcement/…` and `fleet/…`
> are paths inside the **vendored canon tree** (`canon/` in the org governance repo).
> `org-governance/…` is the org's own L1 tree: its roster (`org-governance/fleet/repos.json`),
> its products (`org-governance/fleet/products.json`), its org overlay
> (`org-governance/org.canon-policy`) and its intake track (`org-governance/Documentation/`).
> Mechanism names are canon's: the `canon-policy` fence, the per-repo `.canon-policy` overlay, the
> `canon-worktree.lease` file, the `canon-board` / `canon-index` kernels and `CANON_*` environment
> variables. During the one-major alias window the pre-canon org-prefixed names are still read as
> aliases (`standards/layering.md` lists them); write only the canon names.

> **Policy values are resolved, not read off one file.** Every policy key named below
> (`release.sign_tags`, `release.require_release_notes`, …) has a canon default and an override
> class, and resolves key by key canon → org → product → repo. Where a procedure says "if the
> resolved value is …", read it with `canon-board policy-effective <repo>` (or the repo's resolved
> overlay); never assume the canon default is what a repo runs.

---

## 0. Reading product state — the in-repo funnel is the system of record

The most common request is to **report a product's state** — "give me the status of `widget`,"
"what's next on `widget`," "what's in the backlog for `widget-api`," "where does `widget` stand."
This section governs **where that answer comes from**, before any reporting work begins.

**The answer is always read from the governed repo's own funnel artifacts, in the repo.** State is
read, never inferred (§3), and `STATUS.md` is the source of truth for where things stand (§1, §8).
Resolve the named product to its repo(s) through the org roster `org-governance/fleet/repos.json`
(and `org-governance/fleet/products.json` for a multi-repo product) — the single source of truth for
which repos are governed; **never glob the workspace folder.** A product not listed there is **not
under governance** — say so, rather than reaching for a tool.

**Read order for a state question (all in-repo):**

1. **`STATUS.md`** — the at-a-glance dashboard across outcomes, and the source of truth for where
   things stand (§8). Start here.
2. **`Outcomes/<slug>/`** — the live SOWs, for the detail behind a status line (the Status field +
   Phase Transitions log, §2–§4).
3. **`ROADMAP.md`** (Now · Next · Later) — for "what's next" (§1).
4. **`BACKLOG.md`** — for "what's in the backlog / untriaged signal" (§1).

(Artifact naming and location can vary by repo — a roster `docDir` may point at a lowercase
`documentation/`, for example. Discover them in the repo; don't assume.)

**External trackers are not the starting point and not the system of record.** Do **not** open an
external / SaaS issue tracker to answer a state question. The in-repo funnel is authoritative; an
external tracker is consulted **only** when the operator explicitly asks for it, and even then its
contents are reconciled against the in-repo funnel — which **wins on any disagreement** (the same
precedence §1 gives `STATUS.md` over `ROADMAP.md`, and §3 gives the SOW Status field over
inference). If the in-repo source is thin or missing, **report that gap** (and capture it as backlog
signal) rather than substituting an external tool as the source of truth.

Load this skill and the repo's repo-tier skill before reporting — the always-on floor applies to a
status request exactly as it does to an edit.

---

## 1. The funnel: Backlog → Roadmap → SOW → Archive

Raw signal enters cheaply and is triaged into the outcome model. Forcing every idea into full
SOW ceremony is too heavy (so it doesn't happen and signal is lost); leaving it in chat or a
commit body loses it too. The backlog is where signal lands.

**`BACKLOG.md`** (repo `Documentation/` root) — the intake board, the front of the funnel.
- Capture feature requests, bug reports, design ideas, code-review requests, and tech-debt here
  **first**, as a single item — **not** as a premature SOW. A backlog item has no DoD, no
  behavior-verb requirement, and no subfolders. It is explicitly *not* an outcome.
- **IDs** are four-digit, sequential, immutable once assigned. Their written form follows the org's
  **`ids.form`** key (`standards/terminology.md`):
  - `ids.form = qualified` — bare `BL-NNNN` inside its own repo; from any other repo, prefixed with
    the roster repo name: `<repo> BL-NNNN`.
  - `ids.form = prefixed` — `<PRODUCT>-BL-NNNN` everywhere.

  Either way **every citation must be unambiguous across repos**, and canon tooling parses both
  forms. Below, `BL-NNNN` stands for whichever form the org uses.
- **Type** ∈ { Feature · Bug · Design-idea · Code-review · Tech-debt }.
- **Backlog Status** ∈ { `New`, `Triaged`, `Active`, `Implemented`, `Closed` } — distinct from
  the SOW Status set (§3). Items don't sit in `New` indefinitely; triage is periodic.
  `New` (raw captured signal, untriaged) → `Triaged` (reviewed, Disposition assigned, not started)
  → `Active` (promoted out of the backlog into committed work — a CR/SOW opened; underway, not
  built) → `Implemented` (built, riding dev→staging, not yet in prod) → `Closed` (in prod /
  accepted).
  **`Implemented`** marks the git-track in-pipeline state: the change is built and merged toward the
  trunk — on dev heading to staging, or soaking on staging — but not yet confirmed on production.
  For a **doc-only governance change with no runtime**, `Implemented` means the edit has landed at
  source but is not yet fully propagated / verified. Close only when the fix is verified where users
  run, or propagation is complete (`done.ends_at_current`). **`Active`** is the graduated-to-SOW/CR
  route. Note: **"promote" is the *action* that moves an item to `Active` — it is not a status**,
  and it is deliberately distinct from the §11 release sense of "promote" (to
  master/staging/prod).
- **Triage assigns a Disposition** that routes the item into existing machinery: promote to a new
  SOW (cite the `BL` id in the SOW Lineage), fold into an existing SOW, route a bug to a hotfix
  (git track), route work owned by another repo to that repo's backlog, or close it
  (won't-fix / duplicate / quick-fix-done).
- **Promotion lineage closes both ways:** the target SOW's Lineage cites the `BL` id, and the
  backlog item's Disposition links the SOW. Neither side dangles.
- **A backlog item is never required to become a SOW.** Declining is a valid, recorded outcome.
  The point is that the decision is captured, not that everything graduates.
- **Representation: one file per item; `BACKLOG.md` is a generated index.** Each item is a
  `Backlog/BL-NNNN-<slug>.md` with YAML frontmatter (`id`, `title`, `type`, `status`, `severity`
  and `found_in` where relevant, `horizon`, `big_idea`, `reporter`, `opened`, `updated`,
  `disposition`) and a prose body carrying all narrative, triage notes, lineage, and an
  append-only `## Log`. Start from canon `templates/backlog-item.md`. `BACKLOG.md` holds the static
  how-to/conventions header plus a **generated** block (between `BEGIN/END GENERATED INDEX`
  markers) that is a pure projection of the frontmatter — one thin line per item, grouped by
  `horizon` — regenerated by `enforcement/canon-index` (`canon-index index <Documentation-dir>`),
  never hand-edited, and never holding prose or history.
- **Prioritization is `horizon` ∈ { `now`, `next`, `someday` }** (default `someday`), *not* a P1–P4
  scheme: `now` = the short list, `next` = queued, `someday` = parked/unspecified. It shares the
  `ROADMAP.md` **Now / Next / Later** vocabulary (someday ↔ Later), so backlog and roadmap speak one
  horizon language and the roadmap's Now/Next can be generated from `horizon`. `horizon` and
  `big_idea` are set at triage; capture stays low-friction (a new item is just `New` / `someday`).
- **No board-level changelog.** Per-item history lives in each item's `## Log`; cross-item history is
  git. There is no `Last updated:` line and no board-wide `CHANGELOG.md` — an accreting changelog is
  exactly the thing that rots a board, and git already records what changed when.

**Signal about governance itself goes to a governance intake track, not a product backlog.**
A gap in *these* universal standards, the shared governance skills, or the enforcement layers is
**not** a product outcome — every product inherits it — so it does not belong in any product
`BACKLOG.md`. Two tracks exist above the product boards:

- **The org governance track** at `org-governance/Documentation/` (the org's own backlog and
  **Change Records**, ids in the org's track form — `standards/terminology.md`). A promoted item
  becomes a Change Record rather than a SOW, because a standards/skill edit has no running-app DoD —
  "done" there means *source updated + every inheriting copy re-synced*. This is where org-tier
  (L1) signal lives: the roster, identities, host names, org-only skills, the org overlay.
- **The canon track** (`intake/` in canon; ids `CANON-BL-NNNN` / `CANON-CR-NNNN`). Signal about L0
  itself is raised on the org track first and **escalated to canon as a proposal**; only the canon
  owner approves an L0 change record, and an org never edits its vendored `canon/` tree (a sync
  commit is the only way it changes).

Product backlogs are for product outcomes only; if framework-tier signal lands in one, route it to
the governance track (Disposition "→ governance intake track"), and vice-versa. Full rules: the
org track's `README.md` and canon `intake/README.md`.

**Staging / release-candidate feedback (the RC-remediation lane).** Signal found while testing an
active release candidate is captured on the same board, but it also carries release-blocking weight
the general backlog does not track. Such an item gets its normal `BL-NNNN` item (with
`found_in: <vX.Y.Z-rcN>`) **plus** an entry in the board's `## RC Remediation — <active rc tag>`
lane, tagged with a **Severity** (Blocker · Major · Minor). A **Blocker** must be fixed — on a
**`bugfix/*` branch off the trunk**, promoted to the trunk by the §11 procedure, and the candidate
**re-cut at `-rcN+1`** — before that RC may promote to production; non-blockers may be deferred to
normal triage. The fix reaches the candidate **through the trunk**, never by committing on
`release/staging` or branching off it: cutting an RC resets `release/staging` to the trunk, so a fix
made off the candidate is discarded by the next cut (`standards/git-branch-roles.md`, the hotfix
rule). There is no `stabilization/*` branch type. The lane is the capture-side companion to the
no-regression gate (§11): an RC promotes only when every Blocker in its lane is `Fixed`. Capturing
and triaging into this lane is operationalized by the `backlog-intake` skill.

**`ROADMAP.md`** — forward-looking intent, grouped **Now · Next · Later**.
- Expresses *what we intend to do and roughly in what order* — **not** status, not dates.
- `STATUS.md` is the source of truth for where things stand; if the two disagree, `STATUS.md`
  wins.
- Every roadmap line traces to a SOW or a `BL-NNNN`. If it traces to neither, it's an idea that
  belongs in the backlog first.
- Shipped work leaves the roadmap (it lives in `STATUS.md` and the release notes); the roadmap
  stays forward-looking.

**`Outcomes/<slug>/`** — one folder per outcome, holding the SOW plus its stage subfolders. See §2.

**`Outcomes/_archived/<slug>/`** — completed or cancelled outcomes, flat. See §4.

---

## 2. The SOW — the contract for one outcome

A **SOW** (Statement of Work) lives at `Outcomes/<slug>/SOW-<slug>.md`, one per outcome, where
`<slug>` matches the folder name (kebab-case). Create one by copying
`Outcomes/_template/SOW-template.md` — never edit the template in place.

**Four rules define a valid SOW:**

1. **It names an outcome, not an implementation.** A SOW describes a concrete observable behavior
   a user experiences ("the list reflects a new comment within 2s, without a manual refresh"),
   not a code change. **Titles use behavior-verbs** — `deliver`, `ensure`, `enable`, `guarantee`,
   `within`, `you can now` — **never code-verbs** (`migrate`, `refactor`, `rewrite`,
   `consolidate`, `unify`). If a title starts with a code-verb, **reframe it** as the outcome the
   implementation serves before continuing.
2. **Its Definition of Done is a test against the running app** — not merged PRs, not a phase
   number. The DoD is a scenario a person (or an e2e suite) can run against the deployed product
   and observe pass or fail. If you can't write the DoD as a runnable scenario, the outcome isn't
   concrete enough yet.
3. **One SOW per outcome — expand an existing SOW before you fork a new one.** Before you
   **propose *or* start** a SOW, **search `Outcomes/` (both the active outcomes and `_archived/`)
   for an existing SOW whose outcome already covers — or could reasonably be *expanded* to cover —
   the work in question.** Match on the **user-observable outcome, not the implementation**, so
   adjacent and overlapping work is caught, not just an identical title. **If such a SOW exists,
   expand / update it** (preserving prior text — §5, and recording the added scope in its
   Revisions/Lineage) rather than opening a second — **a new SOW is the fallback, taken only once
   you have confirmed no existing outcome can absorb the work.** If scope grows, update the existing
   SOW. If an outcome genuinely splits, retire the old SOW and create new ones — but **never let two
   active SOWs overlap, and never open a duplicate SOW for work an existing one can hold.**
4. **It carries a Status field and a Phase Transitions log** (§3, §4.5) and a Lineage section
   (§7). Status is explicit and updated at the transition moment.

**Folder discipline:**
- An outcome folder has **exactly three allowed subfolders** — `Architecture/`, `Engineering/`,
  `Review and Remediation/` — created when work leaves `Planned`. No `Build/`, no `notes/`, no
  `misc/`, no duplicate folders. (The "build" is code in the product's source tree, not a doc
  folder — a build *document* is either an Engineering handoff or a Review/Remediation artifact.)
- **No documents at the outcome-folder root except the SOW.** Plans, designs, reviews live in the
  three subfolders.
- If a doc doesn't fit one of the three subfolders, **ask before creating it.**

---

## 3. SOW Status (required, explicit, never inferred)

Every SOW carries a Status field near the top, exactly one of:

| Status | Meaning |
|---|---|
| `Planned` | No subfolders yet. |
| `In Architecture` | System design underway. |
| `In Engineering` | Implementation planning / build underway. |
| `In Review` | Review / remediation underway. |
| `Done` | DoD passed on the running app; moved / moving to `_archived/`. |
| `Paused` | Stays under `Outcomes/`; reason + date noted. |
| `Cancelled` | Moves to `_archived/` with a cancellation note. |
| `Superseded by <slug>` | The DoD was **not** met and a different SOW now carries the same user-facing goal — usually because the mechanism changed, not the goal. Stays under `Outcomes/`; see §3.1. |

**Status is read from this field, never from folder location.** Update it at the transition
moment and log the transition (§4.5).

### 3.1 `Superseded by <slug>`

This value exists because each of the other seven is a **false statement** about an outcome whose
goal outlived its mechanism. `Done` asserts a DoD that did not pass. `Cancelled` abandons a goal that
is being delivered right now under a different SOW. `Paused` implies a resumption that will never
come. And leaving it `In Engineering` shows work in flight that nobody will ever pick up.

Four obligations come with it:

1. **Name the successor in the status.** A bare `Superseded` says the outcome stopped without saying
   where the goal went, which loses the only fact a reader needs. The `<slug>` is the successor's
   outcome folder.
2. **It stays under `Outcomes/`** until the successor reaches `Done`, then both archive together.
   This is a deliberate **exception to §4's "moving into `_archived/` is the only retirement
   path"** — a superseded SOW is frequently the only surviving record of what shipped under the old
   approach, and archiving it early buries the material the successor's reviewers need.
3. **Record it in both SOWs.** Predecessor: Status + a Phase Transition. Successor: Revisions +
   Lineage. Lineage closes both ways or the trail is one-directional and unfollowable from the
   surviving document.
4. **Transfer remaining scope explicitly**, naming where each piece landed. This is the whole point
   of the ceremony rather than a formality: unnamed scope is silently dropped or silently built
   twice, and both are discovered late.

Distinct from `Cancelled` (goal abandoned) and from `Done` (DoD passed). Borrowed deliberately from
the ADR track's existing `Superseded by ADR-NNNN` rather than invented — same problem, same shape,
one vocabulary across both tracks. An org cannot add SOW status values by addendum (the set is an
L0 enum); a new value needs a canon change record.

---

## 4. Lifecycle

1. **Idea → SOW.** **First run the expand-before-fork check (§2 rule 3): open a new SOW only once
   you have confirmed no existing SOW — active or archived — can be expanded to cover the work.**
   Then copy the template into `Outcomes/<slug>/SOW-<slug>.md`, Status `Planned`.
   A SOW frequently originates as a promoted backlog item — cite the `BL-NNNN` id in Lineage and
   set the backlog item's Disposition to point back.
2. **SOW → Active.** When work starts, create the three subfolders. The SOW stays at the root as
   the source of truth for scope. Update Status to `In Architecture`, log it, update `STATUS.md`.
3. **Active expansion (Architecture → Engineering → Build → Review).**
   - System design and locked decisions → `Architecture/` (outcome-scoped ADRs included).
   - Implementation planning → `Engineering/`.
   - The **build** happens in the product's source tree against the Engineering plan — no doc
     folder; the output is code.
   - Reviews and corrective work → `Review and Remediation/`, each pass numbered.
4. **Completion.** When the DoD passes **on the running app**: set Status `Done`, log the
   transition, update `STATUS.md`, then move the **entire** outcome folder to
   `Outcomes/_archived/<slug>/`, **flattening** the three subfolders (no subfolders inside an
   archived outcome). Every archived outcome must contain a `SOW-<slug>.md` (a retroactive stub is
   allowed for pre-policy archives).

**Never delete history.** Moving into `_archived/` is the only retirement path — with **one
exception**: a SOW at `Superseded by <slug>` stays under `Outcomes/` until its successor reaches
`Done`, then both archive together (§3.1).

### 4.5 Phase Transitions log

Every SOW carries a Phase Transitions section at the bottom — one dated line per transition,
naming prior → new status and pointing at the doc that triggered the move. This makes history
reconstructable without diff-mining git. **Every Phase Transitions entry updates `STATUS.md` in
the same session** (§8).

---

## 5. The SOW is a living document; keep the chain in sync

A SOW is not a freeze-once contract — it's the canonical statement of what the work is, where it
is, and what "done" means, and all three evolve.

**Update the SOW when:** work transitions phases; an Architecture/Engineering/Review doc locks a
decision that changes or constrains scope; a review surfaces a defect that creates or invalidates
an acceptance criterion; scope expands, contracts, or shifts; or an open question is resolved.

**Preserve prior text.** When scope or acceptance criteria change materially, keep the old text —
inline as a struck/superseded note or in a Revisions section — with date and reason. A SOW must
not silently rewrite its own history.

**Same-session synchronization (no doc lags the others).** When a downstream doc changes in a way
that affects scope, acceptance criteria, locked decisions, or work phase, the SOW is updated **in
the same edit session** — they land together. The rule applies to every pair in the chain: an
Engineering plan that changes architectural assumptions updates the Architecture doc alongside it;
a Review pass that invalidates an Engineering plan updates that doc and files a remediation plan in
the same session. When propagation can't complete immediately, **record the gap**: the downstream
doc notes "SOW update required: <what>" with the date, and the SOW gets a placeholder line in Open
Questions. Close it next session.

---

## 6. Namespacing, labels and terminology

**The binding text is canon `standards/terminology.md`** — item labels inside planning docs, how
IDs are written and cited across repos (`ids.form`), numbering scope, canonical headings, and the
shared abbreviations. This section only points at it; do not restate its rules here or in a
repo-tier skill. The short version an agent needs in hand:

- **One letter, one concept, every tier:** `E1` increment · `OQ1` open question · `D1` decision ·
  `Sc1` acceptance scenario · `R1` risk · `NG1` non-goal · `F1` review finding · `T1` test case.
  An FE plan's increments are `E#`, not `F#`.
- **Spelling:** no hyphen/space/dot inside a label (`OQ1`, not `OQ-1`; `Sc3`, not `Sc. 3`), ASCII
  only, never renumbered or reused.
- **Scope:** `E`/`OQ`/`D`/`Sc`/`R`/`NG` are numbered once per outcome per repo — a downstream doc
  continues the SOW's sequence, it does not restart.
- **Record ids follow the org's `ids.form`** (§1): `qualified` (bare inside the repo, `<repo>
  BL-NNNN` / `<repo> ADR-NNNN` / `<repo> <slug> E4` from another repo) or `prefixed`
  (`<PRODUCT>-BL-NNNN` everywhere). **A citation of another org's record names the org**
  (`<org> <track-id>`), and a citation of a canon record uses its `CANON-*` id.
- **Code comments and test names** always qualify (`BL-0108 E3`).
- **Lint:** `fleet/check-labels.sh` (advisory; parses both id forms).

Because the outcome-model is identical across products, work, reviewers, and agents move between
them without relearning — the only thing that distinguishes them is the namespace, and an
unambiguous id form is what keeps a future product merge from forcing a renumber. SOW slugs stay
product-prefixed where a collision is possible.

---

## 7. Lineage on every downstream doc

Every Architecture, Engineering, and Review and Remediation doc opens with a **Lineage /
Source Documents** section listing: the governing SOW (path); the originating backlog item
(`BL-NNNN`) if promoted from the backlog; upstream docs it builds on; for reviews, the pass
number and prior pass; for remediation plans, the review/audit that surfaced the findings; and any
product-codex contracts the work conforms to. Update Lineage when the upstream chain changes.

**Require a SOW reference** for any Architecture/Engineering/Review doc. If none exists, propose
creating one first (copy the template) rather than writing an orphan doc.

**Start from the template.** Each product's `Outcomes/_template/` (seeded from canon
`templates/sow/`) holds `SOW-template.md`, `engineering-plan-template.md` and
`review-template.md`. They carry the canonical headings and item labels
(`standards/terminology.md`): an engineering plan's increments are `E#`, and it **continues** the
outcome's `OQ#`/`D#`/`R#` sequences rather than restarting them (§6).

---

## 8. `STATUS.md` is a derived view, kept in sync

`STATUS.md` is the at-a-glance dashboard across every outcome. It is a **derived view, not a source
of truth** — it drifts the moment a transition lands without updating it.

**Any change to a SOW's Status field, a SOW's Phase Transitions log, or the `adr/` directory MUST
update `STATUS.md` in the same edit session.** If propagation can't complete in the same session,
record a "STATUS.md update required" line in the triggering doc and close it next session. The same
applies to the release-lines block whenever a release ref moves (§11, cut-RC step 6 and
promote-to-production step 6).

---

## 9. ADR registry

Repo-level ADRs (cross-app architectural choices that outlive any single SOW) live under
`adr/` with an index, a numbering convention, and status values. Outcome-specific decisions live
inside that outcome's `Architecture/` folder instead. Changes to the `adr/` directory update
`STATUS.md` in the same session (§8).

### 9.1 Amending a decision — three things, not two

When one document amends or supersedes another — an ADR amending an ADR, a Change Record amending a
Change Record — the amending document does **three** things:

1. **State the new decision in its own text.** The amending document must stand on its own.
2. **Record the relation in the amended document's header** — `Superseded by …` / `Amended by …`,
   naming the amending document and dated.
3. **Mark the amended clause in place, in the amended document's body**, naming the amending
   document and saying in one line what changed. For example:

   > **⚠ Reversed by ADR-0012 (2026-01-15): the posture below is superseded — tenants may no longer
   > be left unencrypted.**

**(3) is the one that gets skipped, and it is the one the reader depends on.** Someone who opens a
document and reads its Decision section does not read the header first. They take away the
superseded rule, with nothing at the point of reading to warn them. A header entry is an index; it
is not a warning to the person already reading the clause.

#### Why this is a rule and not a style note

Measured across one org's roster, **four of six** recorded amendments were header-only. That
distribution rules out "be more careful" as the fix, and the shape of the failures says why:

- an ADR amending one closely-worked sibling updated the body ✓
- an ADR performing a **reversal** marked the clause inline ✓
- an ADR sweeping across several older documents updated its own text thoroughly and the others'
  headers only ✗ ✗ ✗
- one ADR did both halves in a single change: its **reversal** landed inline, its two **widenings**
  did not

**Loud amendments propagate; quiet ones do not.** A reversal feels like it needs announcing, so it
gets announced. A widening or a narrowing does not feel that way — and it is exactly the kind a
reader will not suspect, so it needs the inline marker **more** than a reversal, not less. The same
asymmetry explains the sweep: amending several documents at once is when the per-document work is
most likely to be skipped, and it is also when the most readers are affected.

It is consequential, not cosmetic. In the recorded case a live design decision turned on whether
tenants may be left unencrypted, and the two ADRs anyone would open to settle it both stated the
pre-amendment rule.

#### The check, and what it deliberately cannot do

Two surfaces run the same check, roster-scoped, over `Documentation/adr/` and outcome-scoped
`Outcomes/*/Architecture/`:

- the **`canon-board` kernel's `adrs` payload** (and the `sweeps` verb), as an advisory per ADR;
- **`fleet/check-adr-amendments.sh`** / `canon-board adr-amendments`, which exits 0 by default and
  1 only with `--strict`.

Both ask whether the amended document names the amending one **anywhere outside the metadata bullet
that records the relation**. They cannot tell whether the marker sits at the right clause, or
whether its wording is any good.

That looseness is deliberate. It catches the failure that actually happens — a whole body left
untouched — with no false positives. A stricter proxy would police wording, produce false alarms,
and be switched off, which is worse than a loose check that is trusted. **Do not "improve" it into
something that false-positives.**

The check is **advisory on introduction**: it reports; it does not block. Making it blocking (wiring
`--strict` into an audit's failing set) is a separate, visible act. An org whose ADR house style
records the relation differently (for example inside the `**Status:**` bullet rather than under an
`Amended by:` label) records that style as an L1 addendum, and the check must tolerate it rather
than misread a compliant document as a gap.

---

## 10. Lineage-grounded code review (meta-model)

When asked for a "code review," "audit," "review this," or any equivalent for SOW-governed work,
the review **must be grounded in the full document lineage** — a review that only reads the diff
is non-compliant.

**Required reading order BEFORE writing the review:**

1. The **SOW** (`Outcomes/<slug>/SOW-<slug>.md`, or under `_archived/` if archived).
2. **All Architecture docs** in that outcome's `Architecture/`, plus any repo-level ADRs they cite.
3. **All Engineering docs** in `Engineering/` — every plan, not just the one for the code in hand.
4. **Prior Review and Remediation docs** — number this review correctly; don't re-litigate
   resolved findings unless regression is suspected.
5. The **relevant product-codex contracts** the work must conform to (the repo-tier skill names
   the specific codex for that product).
6. The **actual code change**.

The review document then: states which SOW, Architecture, Engineering, prior reviews, and codex
contracts were consulted (paths); cross-references findings to SOW acceptance criteria and
decisions ("Violates ADR-0003," "Drifted from <contract §x>"); lists carried-forward remediation
items and status; is saved to `Review and Remediation/` with a numbered filename; and if
remediation is needed, **files a paired remediation plan and updates the SOW in the same
session**. **If any required upstream doc is missing, STOP and report the gap.**

**Machine-readable verdict (feeds the review gate).** Where `master` is review-gated (§11), the
review document ends with a one-line verdict footer the gate consumes — an HTML comment so it does
not render:
`<!-- canon-review: reviewer=<bound-id> verdict=<PASS|CHANGES_REQUESTED|FAIL> sha=<full-commit> review=<doc-path> -->`.
`verdict=PASS` only when every in-scope criterion is met with no missing lineage. **Every new commit
a push brings to `master` must be covered by a passing review** — not only the tip; one review may
cover several commits, carrying one `sha=` token per commit. A read-only auditor agent does not push
the review record itself; a separate emitter running under the auditor identity parses this footer
and writes the protected review note to `refs/notes/canon-reviews` (mechanism in canon
`enforcement/`). The gate accepts a note only when the pushing identity **is** the named reviewer.
The repo tier binds the concrete reviewer id (`master.review_reviewer` in `.canon-policy`).

**Where a gate review lives (canon 1.4.0, CANON-CR-0003).** The review that clears a push is
recorded **in the repo's own review note**, not committed anywhere. A committed review document
would itself be a new commit on `master` needing its own review. The emitter writes:

- a record line (`reviewer=… verdict=PASS sha=… review=notes …`) on every covered commit;
- the document's body, each line prefixed `| `, once, on the newest covered commit.

The gate trusts **only lines that begin with `reviewer=`**, so a body that quotes a footer can
never pass it. The kernel composes and reads these reviews: `review-status`, `review-draft`,
`review-emit` and `review-show`; the BacklogBoard Ship tab is their editor. Do not commit gate
reviews to the governance repo or to the product repo. A SOW-level review in
`Review and Remediation/` is different: it is part of the work and ships in a reviewed push like any
other document.

---

## 11. Universal git / branch / release standards

These are the platform-wide standards (canonically `standards/git-branch-roles.md` + its policy
block). They apply to every governed repo identically. Wherever this section says **`master`**, read
the repo's roster `trunk` (default `master`); the protected set is that trunk plus every
`release/*` ref.

**Branch model — one trunk, and a release model each repo declares.**

`master` is the integration trunk in **every** model, and these rules hold under all of them:
merges into `master` are **`--ff-only`**, **one clean commit per feature**, **no merge commits**,
and feature branches are **deleted after merge**. Every `release/*` ref is protected: never
force-pushed (except `release/staging` while a candidate is active), never deleted, and advanced
only by a fast-forward promotion.

What differs between repos is the **release model** — how work travels from `master` to production.
There is no single correct topology: a small pre-launch app and a multi-service platform with beta
testers need different machinery, and the cost of the heavier model is only justified once there is
something to protect. So a repo **declares** its model, and the declaration can change as the
product matures.

**A repo's release model is declared in the roster (`org-governance/fleet/repos.json`) as
`releaseModel`,** beside `scope`, `tier` and `trunk`. The roster is the single source of truth for
repo shape; the release model is part of that shape. A repo with no declaration is treated as
`trunk-only`.

| Model | Refs beyond `master` | Candidates | Tags | "Promote" means |
|---|---|---|---|---|
| `trunk-only` | none | — | — | nothing to promote — not released yet |
| `rolling-pair` | `release/current`, `release/previous` | — | `vX.Y.Z` on `current` | rotate `current` → `previous`, ff-only `master` → `current`, tag |
| `staging-soak` | `release/staging`, `release/current`, `release/previous` | `vX.Y.Z-rcN` on staging | `vX.Y.Z` on `current` | cut a candidate, soak it, promote the soaked candidate to `current` |

**`trunk-only`** — the repo has no release refs. Work lands on `master` and either isn't deployed
yet or is deployed from `master` ad hoc. This is the honest state for a product before its first
release, and it is a *declared* state, not an absence: tooling should report "not released yet"
rather than flagging a missing production ref as a defect. It is the only model with **no rollback
story**, which is precisely why it ends at first release.

**`rolling-pair`** — the default for anything deployed. `release/current` is what is shipping;
`release/previous` is what it replaced; promotion rotates the pair and tags the new release. No soak
lane and no release candidates: work goes from `master` to production in one promotion. Right when
the surface is small, the user set is trusted, and a standing second environment costs more than the
risk it retires — but **every deployed thing gets a rollback path**, because the cost of the pair is
one extra ref and the cost of not having one is discovered at the worst possible moment.

Rollback has two tiers, deliberately:

- **One step back, immediately** — redeploy `release/previous`. No lookup, no decision; the ref *is*
  the answer to "what was running before this?"
- **Any release, ever** — redeploy its tag. Tags are immutable markers on `release/current` at each
  promotion, so the full release history stays addressable after `previous` has rotated past it.

Both are required. A pair without tags can only ever undo the last promotion; tags without a pair
make the common case — *undo what I just shipped* — a lookup under pressure.

**`staging-soak`** — the full lane. `master` is cut onto `release/staging` as a candidate tagged
`vX.Y.Z-rcN`, which soaks; a passing candidate is promoted to `release/current`, and the outgoing
release rotates to `release/previous`. Right once there are users who did not sign up to be tested
on — beta testers, external customers, anything where a bad release costs more than the machinery.
It is `rolling-pair` plus a proving ground, so the rollback story is unchanged.

**Choosing.** Take the lightest model that covers the risk you actually carry, and note that the
menu ratchets: `trunk-only` until first release, `rolling-pair` from then on, `staging-soak` when
there are users who would be harmed by a bad one. Moving down is permitted but rare and should say
why. Adopting a heavier model before there is something to protect is the failure these three exist
to prevent — ceremony that does not get performed, which is worse than no ceremony, because the
documents then lie about what the team does.

**Model-scoped rules.** Some standards apply only under some models — release candidates and their
`-rcN` discipline exist only in `staging-soak`, and a release-notes gate is meaningful only where
releases are versioned events. A policy key that does not apply to a repo's declared model is not
violated by that repo; it is *inapplicable*, and tooling must not report it as drift. Equally, a
procedure scoped to one model **refuses** on a repo that declares another — it never creates the
refs it expected to find.

**Changing a repo's release model** is a **governed operation, not a field edit**. The declaration
is false until the refs exist, and a roster that describes a topology the repo does not have is the
same defect as a standard nothing implements.

1. **Record the decision in the repo** — an ADR naming the current model, the new one, and what
   changed to justify the move (first release, users acquired, a beta cohort, an outage that soak
   would have caught). The ADR is the reason; the roster is only the declaration.
2. **Create and seed the refs** the new model requires, from the appropriate base. Entering
   `rolling-pair` means creating `release/current` **at the commit that is actually deployed** — not
   at `master`, unless `master` is genuinely what is running — and `release/previous` at the prior
   release if one is identifiable (a tag), else at the same commit. Entering `staging-soak` means
   creating `release/staging` and cutting a first candidate onto it.
3. **Update the roster** in the same effort, so the declaration and the refs land together.
4. **Verify** — the declared-vs-actual check reports no drift for that repo.

Refs created by a model change are protected from creation: they are advanced by promotion, never by
direct commit, from their first commit onward. **Tooling validates; it does not migrate** — the
kernel reports declared-model-vs-actual-refs drift as signal for an operator, never as an automatic
fix. Creating protected refs is a deliberate human act.

**Start on a working branch — proactively, before the first change (don't wait for the guard).**
Before you create or edit *any* file in a governed repo, check the repo's current branch. If it is
`master` or any `release/*`, **create a working branch first** (`git switch -c feature/<slug>` — or
`bugfix/*` / `hotfix/*` — off the right base) and make the change there. This is a **behavior you
perform**, not merely a rule the hooks enforce: the `PreToolUse` edit guard (`edit.require_branch`)
is a *backstop*, and there are environments where it does not run (see "Execution environment"
below). If the guard is absent and you've also skipped this step, work silently lands on a protected
branch — which is the exact failure this rule exists to prevent. Treat "what branch am I on?" as the
first question in any repo, the same way "promote to master" (below) makes it step 1.

**Execution environment — where the agent-side guards do and don't run.** The edit and git guards
are **Claude Code `PreToolUse` hooks**. They bite only when (a) they're wired (the managed-settings
floor and/or each repo's `.claude/settings.json`) **and loaded** (hooks load at session start, no
hot-reload), and (b) `CANON_POLICY_PATH` points at a readable policy (a missing policy **fails
closed** — denies — but it must still be *invoked* to do so). In a **Cowork** session, or any runner
that does not execute those hooks, **none of the agent-side guards fire** — the only mechanical
protection is whatever the environment provides (e.g. an OS/mount delete-block), and the real
backstop is the **host gate at push time (see `standards/host-contract.md`)**: ref protection, the
server-side `update` hook reading the repo's resolved overlay, and the review gate. Therefore, where
the hooks may not run, the branch-first and delete-confirm disciplines are **behavioral** — the agent
must self-enforce them — and privileged git (commit/merge/push) is prepared by the agent and run by a
human or CI against the server. Activate the hooks where Claude Code *is* used by deploying the
managed-settings floor and setting `CANON_POLICY_PATH` (canon `enforcement/`).

**Feature-flag-per-outcome.** Each outcome-SOW gets a flag from day one, scoped tightly, so it can
be promoted independently of the bundle it rides in. Implementation can land in main behind the
flag. For a SOW that genuinely can't be flagged (e.g. an all-or-nothing cutover with incompatible
auth), or where the org or product has ruled against flags, the SOW must say **"No flag"** and
explain why — the deviation is recorded, not silent.

**Releases — multi-app/coordinated deploy events.** A Release groups multiple outcome-SOWs that
must ship together because they are mechanically coupled (a breaking shared-lib bump every
consumer must adopt at once, a coordinated multi-app cutover, a backend contract that flips for
every app simultaneously). If outcomes can ship independently behind flags, **don't manufacture a
Release.** A Release has its own SOW and the same three subfolders. Its DoD is the conjunction of
the individual outcome DoDs **plus** release-level gates: every app builds/deploys/loads, and a
**no-regression gate** passes.

**No-regression gate (mandatory for Releases).** Existing user-facing behavior must be unchanged
or improved. *Functional regression* is binary pass/fail via e2e suites where available, manual
walkthroughs where not. *Performance/reliability regression* is compared against a pre-release
baseline, with per-behavior tolerances set in the Release SOW before staging runs. The
no-regression contract list is finite per Release and risk-based (high-traffic, high-value,
changed-code-path flows).

**Agent vs. human enforcement.** Agent commits that violate the branch model are **blocked**
(a `PreToolUse(Bash)` hook); human pushes are caught by the **host gate (see
`standards/host-contract.md`)** — ref protection plus the server-side `update` hook; a CI /
scheduled audit reads the **same** resolved policy and **flags** after the fact. Agent commits are
tagged — an author in the org's `agent.author_domain`, or the org's `agent.trailer_key` trailer
(both L1 values) — so the audit applies block-for-agents vs. flag-for-humans correctly. **Every layer
reads one resolved policy** — never re-encode the rules.

### Concurrent work — one writer per working tree

**A working tree is single-writer — own it before you move its HEAD or edit through it.** A checkout
has exactly one HEAD; two sessions on one repo share it with no built-in mutex, so a second session's
`git switch -c feature/B` moves the first's HEAD out from under it, drags its uncommitted edits onto
the wrong branch, and races on `.git/index.lock`. This is the concurrency twin of "start on a working
branch": the first question in any repo is "what branch am I on?"; the second is **"does anyone else
hold this tree?"** Before the first edit in a session, or before any `git switch`/`checkout`/`switch
-c` that changes the current branch, **claim the tree's lease** (`git rev-parse --git-path
canon-worktree.lease`, per-worktree). If a *different live* session holds it, **STOP and surface** —
never switch its HEAD or edit through it. The model is enforced by `worktree.single_writer`: the git
guard gates the switch and the edit guard gates the edit. This binds the org's governance repo too:
it is not a product-roster entry, but it is exactly the shared checkout two governance sessions
collide on.

**During the rename window, read both lease names.** A tree may carry a legacy org-prefixed lease
file written by an older tool. Every tool **reads both** the legacy and the canon lease, **writes only
`canon-worktree.lease`**, and treats **either one present as held**. Two tools checking different
files would otherwise both see the tree as free.

**Check immediately before, not at the start.** "Before any switch" means *right before that
command*, in the same step — not once at the start of a turn or a session. A check made minutes
earlier is stale the moment another conversation claims the tree, and parallel conversations are the
normal case, not an edge case. Immediately before every command that moves HEAD or rewrites the index
of a checked-out branch — `switch`, `checkout`, `reset`, `rebase`, a `merge` into the checked-out
branch — re-read the lease **and** `git reflog -1`: a checkout or commit in the reflog that you did not
make means someone else is in the tree, whatever the lease says. (This has happened: a rollup's squash
step switched a tree another conversation had claimed ninety seconds earlier, on the strength of a
lease check made at the start of a previous turn.)

**Liveness is session existence, not a wall-clock timer.** The lease records *which* session owns the
tree; `session_info.list_sessions` answers *whether* that session is still alive. A lease is **live**
while its `session_id` is still listed — `running` *or* `idle` (an idle session may be resumed, so it
keeps its claim) — and **reclaimable** only once that session is **gone**. Never reclaim a `dirty`
tree without explicit operator confirmation. (The `PreToolUse` guard can't call `session_info`, so it
falls back to the generous `worktree.lease_ttl_hours` backstop; the behavioral actor, which knows its
own session id and can list sessions, uses existence directly.)

**The lease names the conversation, never the project.** Liveness works only if `session_id` is the
same identifier `session_info.list_sessions` reports. In Cowork:

- **Your id** is your own entry in `list_sessions` — the one whose `cwd` is your outputs directory —
  written verbatim (`session_id=local_<uuid>`). That makes the liveness check a direct lookup.
- **Fallback, only when `session_info` is unavailable:** the conversation segment of your outputs
  path — the directory immediately above `outputs/` — as `session_id=cowork-conv:<segment>`.
- **Never the project/space segment** (the directory above that). Every conversation in a Cowork
  project shares it, so a lease written with it reads as "mine" to every one of them, and a
  correctly timed check still cannot stop a collision.
- **A lease you cannot resolve to a listed session is not yours.** A `cowork-<uuid>` space-id lease,
  or any id absent from `list_sessions`, is treated as held by an **unknown live session**. The same
  applies to a lease whose `branch=` names a branch you did not create, even if the id matches. Stop
  and surface; reclaim only on operator confirmation.

Where a runner injects `CANON_SESSION_ID` for the git-hook tier, it injects this same value.

**Conflict → offer isolation, don't serialize silently.** When another session holds the tree, give
the operator two paths: wait for it to release (a clean handoff — tree committed or stashed, lease
cleared), or open an **isolated worktree**:

```
git worktree add .worktrees/<slug> -b feature/<slug>      # add `.worktrees/` to .gitignore once per repo
```

Each worktree has its own HEAD and its own (per-worktree-resolved) lease and shares the object store,
so both sessions move in parallel without contention. `git worktree add`/`list` are sanctioned
(`worktree.add_allowed=true`); teardown (`git worktree remove`/`prune`/`move`) removes files and stays
delete-gated under `delete.require_confirm` — confirm in guarded environments, `allow_cowork_file_delete`
in Cowork.

**Never leave a dirty tree across a handoff; then release the lease.** Commit or stash before
yielding the tree. **Park HEAD (return it to the trunk) only when the operator instructs it**, or
when the repo resolves `worktree.park_head_on_handoff=true`. Canon's default is `false`. Otherwise,
leave HEAD where the operator expects it, typically on the branch they are reviewing: moving HEAD
under an open review removes the files they have open. The cost of leaving HEAD on a working branch
falls on whichever session next has to switch off it. That switch can **half-apply silently** if it
must remove files: git moves HEAD and the index, while the working tree keeps the old files. That is
why the next rule is unconditional. A completed handoff leaves: no dirty tree, no lease, no stale
`.git/*.lock`, no orphaned worktree, and HEAD on the trunk **if** parking was instructed.

**A partially-applied checkout is a stop condition, not a starting point.** After any `git
switch`/`checkout`, verify it actually took: HEAD is what you asked for **and** `git status` is
clean. A non-empty status immediately after a switch means the checkout was blocked part-way — in
Cowork by the delete-protected mount, which is exactly the `Operation not permitted` case that means
*request `allow_cowork_file_delete` and re-run*. Never build on top of a half-applied checkout, and
never `git add -A` on a tree you have just switched into without reading what is actually there:
those files may belong to the session before you, and they may still be the only copy in the working
tree even though they are committed on a branch.

**Tear down an isolated worktree, or hand it off explicitly.** `git worktree add` is the sanctioned
parallel path (`worktree.add_allowed`), but its registration lives in the per-session gitdir and
**can die with the session** — leaving a directory of files that `git worktree list` cannot see and no
one knows the status of. Before ending a session that opened one: land the work, then remove the
worktree (delete-gated — confirm, or `allow_cowork_file_delete` in Cowork), or state plainly in the
handoff that it is still live and what it holds. A `.worktrees/<slug>` directory that `git worktree
list` does not know about is an **orphaned worktree**: check whether its content is reachable before
touching it, and surface it — never assume it is disposable.

**Cowork caveat.** The `PreToolUse` guards don't run in Cowork, so single-writer is behavioral there
(read the lease + `session_info`, with the lease naming the conversation, and re-read immediately
before each HEAD-moving command — both above). And because an in-place `git switch` between branches
with differing files must unlink/replace files, it fails with `Operation not permitted` until
`allow_cowork_file_delete` is granted — which makes the additive `git worktree add` the friendlier
parallel path in Cowork specifically.

**Actor-agnostic git-hook tier.** Because the `PreToolUse` guards bind only actors that run them (not
a terminal, not Cowork), single-writer also ships as **git hooks** (canon `enforcement/githooks/`)
installed via `core.hooksPath`: a `pre-commit` that **refuses** a commit when a different live actor
holds the tree, and a `post-checkout` that claims the lease and warns on a clobber. These run for
*every* `git` invocation — terminal, script, or agent — so they bind the non-session writers the
guards miss. They reuse the same `canon-worktree-lease.sh` and key off `CANON_SESSION_ID`. When no id
is injected, the helper derives a **stable per-actor id** — it must be the same for two consecutive
commits by the same actor, or the actor's own second commit is refused as if a foreign lease held the
tree. An agent runner must inject a stable id. Deployment is per-repo and operator-run, like the
`PreToolUse` floor — see `enforcement/githooks/install-git-hooks.sh`.

### Promoting work to `master` (the agent procedure)

When the operator says **"promote this to master," "roll this into master," "merge to master,"
"land this on master," "roll it up," "rollup," "clean up,"** or any equivalent, run the procedure
below. **"Rollup"/"cleanup" is this procedure plus the confirm-gated branch delete and a
backlog-reconcile pass — commit, promote to `master`, delete the merged branch, and reconcile the
relevant backlog item(s) (step 5 below) — and nothing beyond that: it does *not* include cutting a
release candidate** (an RC is cut only on explicit instruction — see "Cutting a release candidate"
below, `release.rc_requires_explicit_instruction=true`; the backlog reconcile is
`rollup.reconcile_backlog=true`; both keys are `locked`). It is the agent's operational expression of
the branch model above — it never relaxes a rule, and it is the positive companion to the "never
start or commit work on a protected branch" floor (the `PreToolUse` edit + git guards enforce that
floor mechanically). The human-facing equivalent is canon's `guides/git/` runbook for feature
development; this is the agent's deterministic version of its tail, with an explicit confirmation
gate.

1. **Locate the work — which branch am I on?** Read the current branch
   (`git symbolic-ref --short -q HEAD`). It must be a working branch (`feature/*`, `bugfix/*`,
   `hotfix/*`). If HEAD is detached, or already on `master`/`release/*`, **STOP and surface it** —
   nothing is promoted from a protected or detached HEAD. **A `hotfix/*` branch promotes to `master`
   like any working branch, then reaches production through the trunk** — on a `staging-soak` repo
   cut as a patch RC, soaked, and **fast-forwarded** onto `release/current`; on a `rolling-pair`
   repo fast-forwarded from `master` at the next promotion. A hotfix is **never** committed directly
   on `release/current`, and never cherry-picked onto it or fixed there first and "forward-ported":
   that diverges `release/current` from `master` and breaks the `--ff-only` production advance
   (`release.allow_nonff=false`, `locked`). Production env config (`deploy/<env>/*`) flows the same
   trunk path. Confirm the working tree is clean before going further.

2. **Squash per protocol — one clean, fast-forwardable commit.** Refresh the trunk
   (`git fetch origin`; a `git checkout master && git pull --ff-only` is fine — no file edits happen
   on `master`, so the edit guard does not fire). Rebase the working branch onto the latest `master`
   and collapse it to **exactly one logical commit** whose message reads like a release note — no
   "oops"/"debug" commits (`git rebase -i master`, or the focused
   `git reset $(git merge-base master <branch>) && git add -A && git commit` alternative). This
   satisfies the squash-per-feature practice and is what makes step 3's `--ff-only` succeed.
   *(There is no per-feature commit-count key: a hook cannot tell a batch of clean commits from a
   messy one. The only mechanical cap is `master.max_commits_per_push`, default `0` = no cap;
   squashing per feature remains the practice.)*
   Verify with `git log master..<branch> --oneline` — it must show a single commit — and run the
   commit-content check from "Leave no orphans" **now**, while a bad commit is still a local repair.
   The commit must be agent-attributable (an author in the org's `agent.author_domain`, or the org's
   `agent.trailer_key` trailer), or the `PreToolUse` git guard will (correctly) deny it.

3. **Fast-forward merge into `master`.**
   `git checkout master && git merge --ff-only <branch>`. `--ff-only` is mandatory —
   `master.allow_merge_commits=false`, so a merge commit is forbidden; if the fast-forward fails, the
   branch was not properly rebased — **return to step 2, do not reach for `--no-ff`.** Remember
   `master` is **review-gated where the gate applies** (`master.require_review=true` scoped by
   `master.require_review.applies_to_scope`, canon default `full`): the server-side `update` hook
   rejects the push unless the bound reviewer's passing review note covers **every new commit** the
   push brings. So the lineage-grounded review must have run and passed (§10) — the read-only auditor
   emits the verdict footer the emitter turns into the protected note. **The agent does not push a
   protected ref:** hand the operator `git push origin master`. If the gate blocks the push, surface
   it; do not attempt to work around the review requirement.

   **If another live session holds the tree**, do not `git checkout master` in it — that moves their
   HEAD. Advance the ref without touching the working tree:
   `git merge-base --is-ancestor master <branch>` (must succeed — it is the fast-forward check), then
   `git update-ref -m "ff: <branch>" refs/heads/master <branch> <old-master-sha>`. The old-value
   argument makes the update refuse if `master` moved in the meantime. The result is exactly what
   `--ff-only` produces: no merge commit, one commit per feature, same review gate at push. Step 4's
   delete then uses `git branch -D` **after** `git merge-base --is-ancestor <branch> master`
   succeeds, because `git branch -d` checks against the current HEAD, which here is someone else's
   branch.

4. **Confirm before deleting the branch.** After the promote, **ask the operator** whether to delete
   the now-merged working branch — never auto-delete. On an explicit yes:
   `git branch -d <branch>` and (if it was pushed) `git push origin --delete <branch>`. The branch
   model wants working branches deleted after merge ("if the branch still exists, the feature isn't
   done"), but the deletion is gated on confirmation by operator instruction.

5. **Reconcile the relevant backlog item(s) — surface, don't silently edit**
   (`rollup.reconcile_backlog=true`). A rollup isn't finished when the branch is gone: the work it
   promoted usually implements a tracked backlog item whose status now drifts if it isn't updated.
   Identify the item(s) the work implements by the **backlog id** carried in the branch name, the
   commit subject/scope, or the governing SOW's Lineage — in **whichever id form the org uses**
   (`ids.form`, §1) and on **whichever track the repo belongs to**: a **product** rollup reconciles
   the repo's `Backlog/` item; a **framework** rollup (the org governance repo) reconciles an item
   on the org governance track (`org-governance/Documentation/`). For each, **propose the update and
   ask before writing it** — this is the same confirm-gated posture as the branch delete above;
   **never auto-edit a backlog item.** Because a rollup reaches `master` only — built and
   in-pipeline, **not** verified where users run — the status you suggest is **`Implemented`, not
   `Closed`** (`done.ends_at_current`: an item closes only once the change is live on
   `release/current`); on confirmation, set the status, add a `## Log` line citing the `master`
   commit, keep lineage two-way (§1), and regenerate the index (`canon-index index`). If a SOW's
   Status also moves as a result, update `STATUS.md` in the same session (§8). If no backlog item
   maps to the work, say so and move on — the point is that the decision is recorded, not that an
   item always changes. A rollup ends by **dropping the lease**. It parks HEAD on the trunk only when
   the operator instructs it or `worktree.park_head_on_handoff=true` (above).

> **Never** make this a direct commit on `master`, a `--no-ff` merge, a force-push to a protected
> ref, or a push over the repo's commit cap. Each is blocked by enforcement and by this procedure; if
> a step can't be completed compliantly, stop and surface the conflict rather than routing around it.

### Cutting a release candidate (promote to staging)

When the operator says **"promote to staging," "cut a staging release candidate," "new release
candidate," "cut an RC,"** or any equivalent, run the procedure below. It freezes a coherent
snapshot of `master` onto `release/staging` for QA without stopping development, and it is the
agent's operational expression of canon's `guides/git/` staging-promotion runbook. It is inherently
**cross-repo**: a product candidate may span more than one repo (e.g. a frontend and a backend), and
**each repo carries its own independent RC sequence** (each repo's rc numbers are unrelated — one can
be at `-rc3` while the other is at `-rc8`). Run every step **per governed repo**.

> **Trigger — explicit instruction only** (`release.rc_requires_explicit_instruction=true`, `locked`).
> Run this procedure **only** when the operator has explicitly asked to cut an RC / promote to staging
> **in this session**. **Never cut an RC proactively or as a side effect of another task** — not during
> a "rollup" or "cleanup," not as part of a release sweep or fleet audit, not because `master` has
> accumulated commits, and not because a drift signal (`release.max_master_lead_days`, etc.) fired.
> Those are cues to **surface** that an RC may be warranted and *ask* — they are not authorization to
> cut one. In particular, **"rollup"/"cleanup" means: commit, promote the branch to `master`, delete
> the merged branch, and reconcile the relevant backlog item(s) — it never includes cutting an RC**
> (see "Promoting work to `master`" above). If you are unsure whether the operator wants an RC,
> **ask before cutting**. This floor binds **every** governed repo (and the governance repo,
> vacuously — it has no `release/*`).

> **Model gate — `staging-soak` repos only.** Only a repo whose declared `releaseModel` is
> `staging-soak` has a candidate lane. A `trunk-only` or `rolling-pair` repo is **not in the cut**:
> report it as inapplicable and skip it. Never *create* `release/staging` to make a cut possible —
> that is a release-model change (above), a deliberate human act, not a side effect of a cut.
> (`canon-board release-cut-rc` refuses any repo that is not `staging-soak`.)

The candidate tag scheme is the canon standard `v<MAJOR>.<MINOR>.<PATCH>-rc<N>` (the same
`vX.Y.Z-rcN` the RC-remediation lane references in §1). Version bumps follow the release rules: major
for a major product release, minor for a feature release, patch for a hotfix.

1. **Preflight — drain outstanding work into `master` first.** Before freezing, make sure `master`
   actually contains the intended candidate set. For **each** repo in scope, enumerate working
   branches not yet merged into `master` (`feature/*`, `bugfix/*` with commits ahead of `master` —
   `git branch --no-merged master`). **For each such branch, ask the operator** whether to roll it
   into `master` now; on yes, run the **"Promoting work to `master`"** procedure above for that
   branch before proceeding. Branches the operator declines are simply left out of this candidate.
   (Do not auto-promote — confirm per branch.)

2. **Determine which repos have candidate changes.** A repo is "in the cut" only if it (a) is
   `staging-soak` (the model gate above — the governance repo, which has no `release/*`,
   self-excludes) and (b) has commits on `master` ahead of `release/staging`
   (`git rev-list --count release/staging..master` > 0). Report the set of repos to be cut; if a
   repo has nothing new, say so and skip it. **Safety gate:** if `release/staging` has commits *not*
   in `master` (`git rev-list --count master..release/staging` > 0), the soaking candidate carries
   work the trunk does not have — a fresh `reset --hard master` would discard it. **STOP and surface
   it** (the work must reach `master` through a working branch first) rather than overwriting.

3. **Determine the next RC number — per repo, independently.** For each repo in the cut, decide the
   candidate version `vX.Y.Z`: if a candidate line is already in flight above what production runs
   (the newest `-rc` tag's version is ahead of `release/current`), **continue that version** and
   increment its rc; otherwise this is a fresh line — apply the version bump (major/minor/patch) and
   start at `-rc1`. **Confirm the chosen `vX.Y.Z` with the operator** (offer the tag-derived default).
   Then compute `N` automatically as `max(existing -rcN for that version) + 1` (rc1 if none). Because
   each repo's tags are read separately, each repo lands on its own number.

4. **Execute the cut locally — per repo.** Verify `master` is releasable (builds, tests pass, no
   half-finished work) first; if not, stop. Read the repo's **resolved** `release.sign_tags`
   (canon default `false`; tighten-only, so an org or product may turn it on, never off). Then:
   ```
   git checkout master && git pull --ff-only
   git checkout release/staging && git reset --hard master

   # resolved release.sign_tags = false:
   git tag -a vX.Y.Z-rcN -m "Release Candidate N"

   # resolved release.sign_tags = true:
   git -c gpg.format=ssh -c tag.gpgSign=true \
       -c user.signingkey="$(git config canon.releaseSigningKey)" \
       tag -a vX.Y.Z-rcN -m "Release Candidate N"
   git cat-file tag vX.Y.Z-rcN | grep -q 'BEGIN SSH SIGNATURE' \
       || { git tag -d vX.Y.Z-rcN; echo "UNSIGNED — cut aborted"; }
   ```
   `release/staging` legitimately diverges here — it is the one branch the policy allows to be
   force-updated, and only for an active candidate (`release.staging_allow_force=true`). Do **no
   file edits** while HEAD is on `release/staging` (the edit guard forbids editing on a protected
   branch). Create the tag **after** the reset so it points at the real candidate, never an empty
   one.

   **Where the resolved `release.sign_tags` is `true`, the candidate tag is signed**, because the tag
   is the only signable artifact here: the cut moves a ref to an existing SHA and authors no commit,
   so a consumer verifies with `git verify-tag`, never `git verify-commit`. Staging pulls the `-rcN`
   tag, so the RC is signed as well as the production tag. Three things this step must not get wrong:
   - **Verify the signature landed.** `git tag -a` with an unloadable signing key prints an error,
     **exits 0, and creates an unsigned tag** — hence the `cat-file` check above. Never treat the
     signing configuration as evidence that the artifact is signed.
   - **Fail closed, don't cut unsigned.** No key resolved (`CANON_RELEASE_SIGNING_KEY`, else the
     `canon.releaseSigningKey` git config) means **stop and surface** — an unsigned candidate is a
     candidate no consumer can verify. There is deliberately no `--allow-unsigned` escape.
   - **Roll the ref back if signing fails.** A repointed `release/staging` with no tag identifying the
     candidate is a half-cut RC; restore the prior `release/staging` before surfacing ("Leave no
     orphans").

   `canon-board release-cut-rc` does all of this — it reads the resolved key, refuses in the *plan*
   when signing is required and no key resolves (so the cockpit disables the control rather than
   offering a cut that aborts mid-way), and rolls both the tag and the `release/staging` move back
   on any signing failure.

5. **Notify the operator to push — do not push.** The agent prepares the cut locally and stops. The
   force-push to `release/staging` and the tag push are the operator's to run, so hand back the exact
   commands, per repo:
   ```
   git push origin release/staging --force-with-lease
   git push origin vX.Y.Z-rcN
   ```
   Report, per repo, the chosen version+rc, what `release/staging` now points at, and these push
   commands. Staging deploys from `release/staging` once pushed.

6. **Reconcile the dashboard against the refs — same session, before you report done.**
   `STATUS.md` is a derived view (§8), and a cut changes what it derives from. For each repo in the
   cut, update its release-lines block so the **Soaking** line names the candidate you just tagged,
   and confirm the **Current prod** line still matches `release/current`. The release console
   reports this as the `docs_reconciled` advisory in `cut-rc`'s plan — read it; do not assume it.

   > **Why this is a numbered step and not an agent's good intention.** This job was once assigned
   > to a separate release agent as a mandatory cut/promote step, and the record assigning it closed
   > Done. Nothing ever invoked that agent, and a product dashboard then drifted a full release line
   > through **seven** production promotes while displaying a warning about the previous time it had
   > done so. A check whose only trigger is someone remembering to ask is not a check. This step
   > binds the actor that is already running the procedure, which is the half that works in Cowork,
   > where no `PreToolUse` hook fires at all.

> **Never** cut an RC the operator did not explicitly ask for (the trigger gate above); never cut on
> a repo that is not `staging-soak`; never force-push `master`, `release/current`, or
> `release/previous`; never cut a candidate that would discard soaking work the trunk lacks (step 2
> gate); never let two repos' rc numbers be assumed equal — each is computed from its own repo's
> tags. If any step can't complete compliantly, stop and surface the conflict.

### Promoting to production (advancing `release/current`) — `staging-soak` repos

When the operator says **"promote to production," "ship it," "promote staging to prod," "cut the
production release," "go live with rc<N>,"** or any equivalent, run the procedure below **for a repo
whose declared `releaseModel` is `staging-soak`**. Advancing `release/current` to the soaked
candidate **is** the production-release event — the moment end users get the change — so it is the
most consequential, and most gated, move in the model. It is the agent's operational expression of
the release go/no-go; it never relaxes a rule, and (like cut-RC) the agent **prepares and verifies,
then hands the operator the push** — it does not push a protected ref.

> **`rolling-pair` promote (canon 1.3.0, CANON-CR-0002).** There is no soak lane and no candidate
> tag, so the procedure is shorter:
>
> 1. **Version.** The operator names it (`vX.Y.Z`). The plan suggests the next patch, minor and
>    major after the highest release tag; the agent never chooses silently.
> 2. **Preflight** (`release-promote <repo> --version vX.Y.Z --dry-run`), against `<remote>/*` after
>    a fetch:
>    - the tree is clean, no other live session holds it, and HEAD is on a protected ref;
>    - `release/current` exists and matches the server's;
>    - the trunk head is on `<remote>/<trunk>`, and `release/current` fast-forwards to it with at
>      least one commit;
>    - the tag is a new `vX.Y.Z`;
>    - it can be signed where `release.sign_tags=true`;
>    - the release-notes gate passes where it applies.
>
>    Any NO-GO stops the promote.
> 3. **Execute locally, atomically.** Roll `release/previous` to the outgoing `release/current`,
>    ff-only advance `release/current` to the trunk head, and cut the (signed) tag on it. Any failure
>    rolls every ref and the tag back. HEAD and the working tree are never touched.
> 4. **Hand the operator the push commands** (`release/current`, `release/previous`, the tag); the
>    agent does not push. The cockpit's operator-initiated `--push` is the same posture as
>    staging-soak's.
> 5. **Reconcile `STATUS.md`**, and move the delivered items Implemented → Closed once verified in
>    production.
>
> A `trunk-only` repo has nothing to promote.

> **Why the `--ff-only` advance holds.** The git `release/current` advance is the **integrity record**
> of what production runs (deploy mechanics — how artifacts are built and rolled out — are a product
> detail the repo tier binds). `--ff-only` is what keeps that record honest (forward-only, no
> rewinds, no divergent twins). The fast-forward succeeds **because of the branch discipline, not by
> luck**: `release/current` only ever advances by ff from a soaked candidate and is **never committed
> on directly or cherry-picked onto** — so it stays an ancestor of `master`. Hotfixes and prod env
> config (`deploy/<env>/*`) reach prod through the trunk (→ `master` → patch RC → ff), never as a
> direct edit on `release/current`. If a promote ever *can't* ff, `release/current` has diverged (a
> fix was committed on it or cherry-picked, not flowed through the trunk) — **stop and re-anchor it
> onto the trunk line**, do not force or merge it.

1. **Confirm the candidate is the soaked one.** The production release advances `release/current` to
   the exact commit that soaked on `release/staging` as the approved `vX.Y.Z-rcN` — not a fresh build,
   not `master`. Verify `release/current` will *fast-forward* to that commit (release branches move
   forward only; the `update` hook rejects a rewind). Identify the production version `vX.Y.Z` (the
   rc's version, minus the `-rcN` suffix).

2. **Verify the production gates — all must pass before you prepare anything.** These are the §11
   release gates plus the production-only gate:
   - **No open Blockers** in the candidate's RC-remediation lane (§1) — a Blocker is NO-GO.
   - **No-regression gate** assessed and passing (above).
   - **Release-notes gate, where it resolves on** (see "Release-notes gate" below): if the repo's
     resolved `release.require_release_notes` is `true` and the version falls inside the resolved
     `release.notes_gate_scope` (`minor` = `X.Y.0` releases only; `all` = every release), the bound
     release-notes store must carry an entry for `vX.Y.Z`, written for end users. **If it does not,
     STOP** — the release cannot proceed until the notes are authored. Do not work around this by
     editing the notes on a protected branch; the notes land through the normal working-branch →
     `master` → candidate path before the cut (a missing entry found during soak is a Blocker, fixed
     through the trunk and re-cut), never as a direct edit on `release/current`.

3. **Roll `release/previous` forward first (rollback safety).** Before `release/current` moves,
   advance `release/previous` to the *current* `release/current` commit, so a rollback target exists
   for the release you are about to replace (`release/previous` moves only after a successful
   production release — this is that move, performed as part of the cutover, confirmed with the
   operator).

4. **Prepare the production advance locally — do not push.** Read the resolved `release.sign_tags`
   as in cut-RC step 4.
   ```
   git checkout release/current && git merge --ff-only vX.Y.Z-rcN^{commit}

   # resolved release.sign_tags = false:
   git tag -a vX.Y.Z -m "Production release vX.Y.Z"

   # resolved release.sign_tags = true:
   git -c gpg.format=ssh -c tag.gpgSign=true \
       -c user.signingkey="$(git config canon.releaseSigningKey)" \
       tag -a vX.Y.Z -m "Production release vX.Y.Z"
   git cat-file tag vX.Y.Z | grep -q 'BEGIN SSH SIGNATURE' \
       || { git tag -d vX.Y.Z; echo "UNSIGNED — promote aborted"; }
   ```
   `--ff-only` is mandatory (`release.allow_nonff=false`); if it fails, `release/current` is not an
   ancestor of the candidate — **stop and surface**, do not force. Do **no file edits** while HEAD is
   on `release/current` (the edit guard forbids editing a protected branch, and the release notes
   must already be present from step 2, not patched in here).

   **Where signing resolves on, the production tag is signed** under the same three constraints as
   the RC cut: verify the signature actually landed (an unloadable key yields an unsigned tag at
   exit 0), fail closed rather than tagging unsigned, and roll `release/current` and
   `release/previous` back if the tag cannot be signed — never leave a production ref advanced with
   no verifiable tag naming what it advanced to. The `vX.Y.Z` tag is what a host checks when it asks
   "am I running the release I think I am," so an unsigned one silently converts a mechanical control
   back into a process assertion. One case is easy to miss: **re-running an interrupted promote**
   whose tag already exists at the candidate needs no new signature — but if signing is required and
   that pre-existing tag is *unsigned*, stop; delete it (confirmed) and re-run so the console cuts a
   signed one.

5. **Hand the operator the push commands — the agent does not push.** Production refs are operator-
   /CI-pushed against the host gate; where the release-notes gate resolves on, the `update` hook
   re-checks it at push time and rejects the advance if the version's notes are missing. Hand back,
   in order:
   ```
   git push origin release/previous
   git push origin release/current
   git push origin vX.Y.Z
   ```
   Report the production version, what `release/current` and `release/previous` now point at, the
   release-notes entry that satisfied the gate (or that the gate is off / out of scope for this
   version), and these commands.

6. **Reconcile the dashboard against the refs — same session, once the push lands.** The promote is
   the moment `STATUS.md` (§8) goes stale, and it goes stale in the way that misleads hardest: the
   page keeps stating an old version with full confidence. For each promoted repo, update the
   release-lines block so **Current prod** names the version just shipped, `release/previous` names
   the outgoing one, and the **Soaking** line stops naming a candidate — after a promote
   `release/staging` equals `release/current` and **nothing is soaking**, so a page still advertising
   the shipped candidate as soaking is wrong, not merely stale. Where the repos were promoted as a
   coupled set, say so on each. The release console reports this as the `docs_reconciled` advisory in
   `promote-preflight`.

   > **This step exists because its predecessor was never called** (see the note under cut-RC
   > step 6). Verify by reading the refs, never by recalling what you think shipped — the failure
   > mode here is a confident wrong answer, and a reconcile done from memory reproduces it exactly.

> **Never** force-push `release/current` or `release/previous`; never advance production past an open
> Blocker, a failing no-regression gate, **or — where the release-notes gate resolves on and the
> version is in scope — a missing release-notes entry**; never edit the release-notes store on a
> protected branch to satisfy the gate in place. If any gate fails, stop and surface it — the
> production release waits for the gate, the gate is not waived for the release.

### Release-notes gate (where the resolved policy turns it on)

**When a repo's resolved `release.require_release_notes` is `true`, a production release in scope
must tell end users what changed.** Advancing `release/current` to a version inside the resolved
`release.notes_gate_scope` is blocked until the repo's **user-facing release-notes store** carries an
entry for the version being released. Canon's defaults are the loosest values
(`release.require_release_notes=false`, `release.notes_gate_scope=minor`); both keys are
**tighten-only**, so an org, product or repo may turn the gate on or widen it to `all`, never turn
it off or narrow it below what the layer above set. Under `minor`, **patch releases (`X.Y.Z` with
`Z` > 0) are exempt**: a patch ships fixes/maintenance, not new user-facing capability. This is the
user-visibility twin of the no-regression gate: no-regression protects what users *already* rely on;
the release-notes gate guarantees users can *see what is new*. It is enforced both behaviorally
(here) and mechanically (the server-side `update` hook on the `release/current` push, reading the
repo's resolved overlay, with the CI audit as an after-the-fact backstop). Both layers derive the
shipped version from the `vX.Y.Z` tag at the production commit (fallback: the store's own version
field) and skip the gate for a patch under `minor`; an **undetermined** version **enforces**
(fail-safe).

**What satisfies the gate (version-matched entry):**

1. The bound store — `release.notes_path` in the repo's `.canon-policy` overlay (or the product's
   binding); the *path* is a product detail, the *requirement* is universal (see
   `standards/git-branch-roles.md` "Per-repo binding"). The store is a directory of `<version>.md`
   entries (for a directory, the advance must have **added** an entry whose frontmatter `version`
   matches its filename) or a legacy single file whose declared current version matches. It must
   contain an entry whose **version equals the production `vX.Y.Z`** being released. A store that
   still names the previous version, or carries a placeholder version/date, does **not** satisfy the
   gate. **Bind the store the product actually serves** — a gate on a parallel copy passes while
   users see nothing.
2. The entry is **written for end users**: plain descriptions of what changed and what users can now
   do — **no service or app names, no implementation mechanics**. ✅ "Updates in your list now appear
   within two seconds." ❌ "Migrated the list to the register/subscribe event contract."
3. The notes were **authored through the normal path**, not patched onto a protected branch. They
   land on a working branch, reach `master`, and ride the candidate into staging — so the notes soak
   with the code they describe. Drafting begins at the RC cut; finalizing — a real version and date,
   every shipped user-facing change covered — is a precondition of the production advance, not an
   afterthought.

**Repo split for a coordinated release.** Where a product spans several repos and the user-facing
notes live in one of them (the repo that owns the store) while user-visible changes also ship from
the others, the **owning repo's** store is the gated artifact, and each contributing repo must
**hand its user-facing lines to the owner before the production window** so the entry is complete.
The owning repo's `release/current` advance is the gate that holds the joint release. (The product
binds which repo owns the store — `org-governance/fleet/products.json` `notes` — and the repo-tier
skills say how lines are contributed.)

**Fails closed.** If the resolved `release.require_release_notes` is `true` but no
`release.notes_path` is bound, the production advance is rejected (a gated ref with no store
configured must not silently open) — the same fail-closed posture as the review gate.

### Generating / updating release notes — the multi-repo release console

> **Scope: products with more than one repo** — a product listed in
> `org-governance/fleet/products.json` with two or more member repos and `stamp: true`. Only such a
> product carries a platform release stamp (`YYYY.N`) and a release ledger. A one-repo product (the
> default; every repo no product lists is one) has no stamp: its release notes are just the
> version-matched entries the release-notes gate reads, authored on a working branch like any other
> doc. **The release-console verbs below are `canon-board` verbs that take the product id**; an org
> with no multi-repo product never uses this section.

**Terminology — what the operator means.** When the operator says **"generate release notes," "draft
release notes," "update release notes,"** or **"what shipped since the last release"** for a
multi-repo product, they mean: **author the user-facing notes DRAFT for a platform version — do NOT
stamp, commit, or ship.** Drafting and finalizing are distinct acts: *generate/update* writes the
draft; *stamp* (the cockpit's "Stamp Platform Version" / the `release-stamp` verb) is the separate,
deliberate finalize step. Never stamp or commit in response to a "generate/update release notes"
request.

**Format.** Release notes are **markdown with YAML frontmatter** (`version`, `release_date`,
`product`, `title`, then a free-form markdown body of `## item` headings + bullets) — the same
convention as backlog items. Write the body **for end users**: plain descriptions of what changed and
what they can now do, no service/app names or implementation mechanics (the same voice the
release-notes gate requires).

**Procedure** (run from the workspace via the `canon-board` kernel — the cockpit is a UI over these
same verbs):

1. **Target stamp** — the next `YYYY.N` from the product's release ledger (`products.json` `ledger`)
   unless the operator names one.
2. **Compute what was done** — `canon-board release-delta --product <id>` → for each of the
   product's member repos, the backlog items completed since the product's last stamp
   (`done: true` = status `Implemented`/`Closed`, not merely touched).
3. **Translate, don't transcribe** — group the done items by theme (Big Idea where it helps) and write
   plain-language summaries with bullets. Omit purely internal/infra items or fold them into a short
   "Under the hood" line. Never dump raw backlog ids at users. **A bug title states the *defect*, not
   the outcome:** an item titled "X no longer does Y" (or "…is broken/missing/lost") describes what was
   *wrong*; the fix *restores* Y — so describe the **corrected** behavior, and confirm direction from
   the item's `disposition`/`status` (e.g. "Closed - fixed") before writing. (Example: an item titled
   "Saving a draft no longer keeps attachments" is a fixed regression — attachments **are** kept now —
   so the note must say attachments are kept, not that keeping them was removed.)
4. **Write the draft (never commit)** — `canon-board release-notes-save --product-id <id> --stamp <N>
   --title <…> --body <markdown>` writes the product's draft (`release-notes/drafts/<stamp>.md` on the
   product's ledger board), a **gitignored scratch** file. That is exactly what the cockpit's notes
   editor loads (`canon-board release-notes-get --product-id <id> --stamp <N>`), so the operator
   reviews/edits it there. **"Update release notes"** = read the current draft
   (`release-notes-get`), revise, and save it back.
5. **Stop.** Do not stamp/commit. Finalizing is the operator's separate **Stamp & Commit**:
   `canon-board release-stamp --product <id> --component <repo>=<version> [--component …]` — one
   `--component` per member repo of the product, refused for a one-repo product or a repo outside it
   — which writes the committed notes and the ledger row on a working branch → `master`.

---

### Deleting files (surface, confirm, never route around)

Deletion is a normal, permitted operation — but it is **always gated on explicit operator
confirmation** (`delete.require_confirm`, `locked`), and it is **not** the same thing as deleting
history. Keep the two separate:

- **Deleting history / outcomes is forbidden outright.** SOWs, completed outcomes, backlog items,
  ADRs, status records — these are *archived*, never deleted (§4, §8; "history is preserved, never
  deleted"). Archival is the only retirement path. No confirmation makes this OK. *(This is about
  **deletion vs. archival**, not about timing — §3.1's `Superseded by <slug>` delays **when** a SOW
  archives, and never licenses deleting one.)*
- **Deleting a file as part of legitimate work is allowed — after you ask.** Removing a stale source
  file, a generated artifact, a moved file's old path, scratch output: fine, once the operator has
  said yes.

The rule, every time you intend to remove something:

1. **Surface it.** State exactly *what* will be deleted and *why*, and whether it is tracked
   (recoverable from git history) or untracked (irrecoverable). For anything ambiguous or broad
   (globs, directories, `-rf`, `git clean`), list what it resolves to first.
2. **Get explicit confirmation.** Ask, and wait for a yes. One confirmation covers the specific
   deletion you described, not a standing licence to delete.
3. **Then delete — the simple, recoverable way.** Prefer `git rm <path>` for tracked files (the
   removal lands as a reviewable, revertable commit) over a bare `rm`. Remove exactly what was
   approved.
4. **Never route around a delete.** If a removal is blocked, or you are unsure whether you may
   delete, **stop and ask** — do not reach for a `git worktree` trick, a `reset`/`checkout` that
   orphans files, an **`mv`-to-clobber or move-then-abandon**, a temp-index / `commit-tree` /
   `GIT_INDEX_FILE` trick, or any other workaround to get the effect of a delete you haven't had
   confirmed. A move is not an escape hatch: **a `mv` that overwrites or displaces an existing path
   is a delete** (`mv -f`, or `mv SRC DEST` where `DEST` already exists, or moving a file off to a
   scratch/trash location and abandoning it) and is gated exactly like one — surface it and confirm
   first. A rename to a genuinely *new* path destroys nothing and is fine. Refusing outright is also
   wrong: the answer to "can I delete this?" is to *ask the operator*, not to declare you cannot and
   improvise.

**Enforcement.** The agent-side `PreToolUse` git/bash guard reads `delete.require_confirm` from the
policy and **denies** destructive removals — `rm`/`rmdir`/`unlink`, `git rm`, `git clean`,
`git worktree remove`/`prune`/`move`, `git filter-branch`/`filter-repo`, `find … -delete`, and
**destructive `mv`** (`mv -f`/`--force`, or a `mv SRC DEST` whose `DEST` already exists, so a move
can't be used as an unconfirmed delete-in-disguise; benign renames to a new path pass) — until they
are confirmed. A deny from that guard is the signal to do steps 1–2, not to give up or work around
it; once the operator approves the specific command, it is re-run with `CANON_CONFIRM_DELETE=1`.
(This is the filesystem twin of the edit guard's `edit.require_branch` /
`CANON_ALLOW_EDIT_ON_PROTECTED`; like that guard, it is an agent-side gate that makes deletion
deliberate and auditable, not an unbypassable sandbox.) Branch deletion is governed separately by the
promote-to-master procedure's confirm-before-delete step, not by this file gate.

**Environment-level delete blocks (Cowork) — `Operation not permitted` is a prompt, not a wall.**
In a **Cowork** session the agent-side guards above don't run (see "Execution environment"), but the
host enforces the *same* "ask before deleting" principle a different way: the mounted folders are
**delete-protected at the OS level**, so a delete — or *any git step that must remove a file*
(clearing a stale `.git/index.lock`/`HEAD.lock`, a branch switch that replaces files, a commit/merge
that rewrites the index) — fails with **`Operation not permitted` / EPERM**. **This is not "I can't
delete."** The required action is to **request permission with the `allow_cowork_file_delete` tool**
(it surfaces the approval to the operator), then re-run the operation. Do this *automatically* the
moment you see EPERM on a removal — do **not** report the operation as impossible, and do **not**
reach for a workaround (`git worktree`, `reset`/`checkout` that orphans files, a temp index or
`commit-tree`, editing `.git` by hand). If you ever conclude "I cannot delete/commit/merge here,"
that conclusion is wrong by construction: **ask for the permission instead.** (This is why git write
operations — commit, the `--ff-only` merge, lock cleanup — appear "blocked" until permission is
granted: the unlock is always one `allow_cowork_file_delete` call away.)

### Leave no orphans — every git operation ends in a verified-clean state

A "promote to master," "cut a release candidate," or "delete a branch" is **not done** until the repo
is left clean. The operation either **fully completes** or is **fully rolled back** — it never leaves
residue that makes it look half-finished or broken. This is a mandatory post-condition on every
procedure in this section.

**Clean-state post-condition (verify before reporting "done"):**

- **Working tree clean** — no stray uncommitted or untracked files left by the operation (no
  half-applied edits, no new files stranded on the wrong branch).
- **No stale lockfiles** — `.git/index.lock`, `.git/HEAD.lock`, etc. removed (a leftover lock makes
  every later git command fail and look broken).
- **No temp-object cruft** — orphaned `.git/objects/**/tmp_obj_*` from failed unlinks removed.
- **No scaffold/temp branches the agent created** — any `promote/*` or throwaway working branch the
  agent made to stage the operation is deleted once merged; the agent cleans up after *itself* without
  being asked (the operator's confirm gate is for *their* work branches, not the agent's scaffolding).
- **The merged source work branch is deleted** (per the procedure's confirm-before-delete), so a
  completed promotion doesn't leave the branch lying around looking unfinished.
- **The target ref is exactly as intended** — `master` advanced by the one clean commit / the RC tag
  present on `release/staging` / the branch gone — and nothing else moved.
- **The commit's CONTENT is what was intended, not merely its existence.** Before promoting, assert
  the new commit's tree is **not** the empty tree and that `git diff --name-only HEAD~1 HEAD` is
  exactly the change set you meant to make:

  ```
  test "$(git rev-parse HEAD^{tree})" != 4b825dc642cb6eb9a060e54bf8d69288fbee4904
  ```

  Use `rev-parse HEAD^{tree}` — **not** `git cat-file -p HEAD | awk '/^tree/…'`, which also matches
  any line of the commit *message* that happens to begin with the word "tree" and then hands
  `ls-tree` two SHAs and an empty result; a check that can be confused by prose is not a check.
  **Every other clause above inspects the working tree, the locks, the branches or the refs — none of
  them looks inside the commit**, and "`master` advanced by one clean commit" is fully satisfied by a
  commit that deletes the entire repository. This is not hypothetical: in Cowork the index has been
  silently emptied between a `git add` and the `git commit` that followed it in the same shell
  invocation; `git status --porcelain` printed the staged files correctly, and `git commit` then wrote
  an empty-tree commit and exited 0. Check it **before** the promote, while the bad commit is still on
  a working branch and `git reset` is a local repair rather than a rewrite of a shared ref. The
  general form is worth keeping in mind: **`git status` is a report about the index, not a
  verification of it** — a procedure that trusts `status` and then commits has checked nothing about
  what the commit contains.
- **The lease is released**, HEAD is parked on the trunk **if parking was instructed**
  (`worktree.park_head_on_handoff`, default `false`), and no isolated worktree the session opened is
  left registered-but-abandoned.

**Atomic — complete or roll back, never half-done.** If any step fails or is interrupted, restore the
pre-operation state rather than leaving a partial result: abort the in-progress `rebase`/`cherry-pick`/
`merge` (`--abort`), return to the original branch, drop any temp branch created, and clear any lock or
temp object left behind (requesting delete permission if the environment blocks it — see above). Then
**surface what happened.** Never report success with residue present; never leave the repo in a state
the operator has to clean up by hand.

**Verify, then report.** End the operation with an explicit sweep (tree clean? locks? `tmp_obj_*`?
scaffold branches? target ref correct? **commit content correct?** lease released, and HEAD
parked if that was instructed?) and state the result — "clean" or the precise residue and how it'll be resolved. A clean
closeout is part of the task, not an optional courtesy.

---

## 12. Required behaviors (quick checklist)

- **On any "status / what's next / backlog / where does it stand" question, read the in-repo funnel —
  never start at an external tracker** (§0). Resolve the product via the org roster (and
  `products.json`), then read `STATUS.md` → `Outcomes/` → `ROADMAP.md` / `BACKLOG.md` *in that
  repo*. An external tracker is not the system of record; consult one only on explicit request,
  reconciled to the in-repo funnel (which wins). A product not in the roster is not governed — say so.
- **Before the first change in a repo, check the branch and create a working branch if needed** (§11
  "Start on a working branch"). If HEAD is `master`/`release/*`, `git switch -c feature/<slug>`
  first — proactively, not relying on the edit guard (which may not run in Cowork). "What branch am
  I on?" is the first question in any repo.
- **One writer per working tree — claim it before you switch its HEAD or edit through it** (§11
  "Concurrent work"). The second question in any repo is "does anyone else hold this tree?": check the
  lease (`git rev-parse --git-path canon-worktree.lease`, plus any legacy lease name — either present
  means held) and, in Cowork, `session_info`. If a different live session holds it, STOP — wait, or
  open an isolated worktree (`git worktree add .worktrees/<slug> -b feature/<slug>`). Liveness is
  session existence (listed `running`/`idle` = live; gone = reclaimable), not a timer; never reclaim a
  dirty tree without confirmation. **Check immediately before each HEAD-moving command** (lease +
  `git reflog -1`), not at turn start. In Cowork the lease names **the conversation**
  (`list_sessions` id), never the project/space id, and a lease you cannot resolve to a listed session
  is someone else's. On a held tree, advance `master` with a guarded `git update-ref`, never a
  checkout. The org governance repo is single-writer too.
- **When you yield a tree, release the lease. Park HEAD only when the operator instructs it**
  (`worktree.park_head_on_handoff`, default `false`). Otherwise leave HEAD where the operator
  expects it. And
  **verify every `git switch` actually took**: a non-empty `git status` right after a switch means it
  half-applied (in Cowork, the delete-protected mount) — that is a **stop**, not a starting point.
  Tear down any isolated worktree you opened, or name it in the handoff; surface any orphaned one.
- **Capture raw signal in the backlog, not as a premature SOW.** Open a SOW only when the item is
  concrete enough to carry a running-app DoD — and cite the `BL` id when you do.
- **Governance signal goes to a governance intake track, not a product backlog** (§1). Org-tier signal
  goes to the org track at `org-governance/Documentation/`; signal about canon itself is raised there
  and escalated to canon's track (`CANON-BL-NNNN` → `CANON-CR-NNNN`). Never edit the vendored
  `canon/` tree.
- **Before you propose or start any SOW, check whether an existing SOW can be expanded to cover the
  work** (§2 rule 3) — search both the active outcomes and `_archived/`, matching on the
  user-observable outcome rather than the implementation. **Expand / update the existing SOW rather
  than forking a duplicate**; a new SOW is the fallback, taken only once no existing outcome can
  absorb the work.
- **Require a SOW reference** for any downstream doc.
- **Label items per `standards/terminology.md`** (§6): `E1` increment · `OQ1` open question ·
  `D1` decision · `Sc1` scenario · `R1` risk · `NG1` non-goal · `F1` finding · `T1` test case — same
  letter on FE and BE, no hyphen/space/dot, one sequence per outcome per repo, never renumbered.
  Write record ids in the org's `ids.form` and make every cross-repo citation unambiguous
  (`<repo> BL-NNNN` or `<PRODUCT>-BL-NNNN`); name the org when citing another org's record; qualify
  labels in code (`BL-0108 E3`).
- **Reject code-verb SOW titles**; restate as the behavior delivered.
- **Test the running app, not the code that merged**, when evaluating Done.
- **Use `Superseded by <slug>`** when a different SOW now carries an unmet goal (§3.1): name the
  successor, keep it under `Outcomes/` until the successor is `Done`, record it in both SOWs, and
  transfer remaining scope explicitly.
- **Surface workflow violations** — propose the compliant location for a misplaced doc (engineering
  plan at the outcome root, a stray subfolder, a `Build/` folder, a SOW nested where it shouldn't
  be).
- **Archive on completion**, flattening subfolders; never delete.
- **Preserve traceability** — every doc cites lineage; every review numbers its pass; every
  remediation plan names the review/audit it answers. **An amendment reaches the amended clause**
  (§9.1), not only the header.
- **Keep the chain in sync** (§5) and **keep `STATUS.md` in sync** (§8), same session.
- **Route permanent contracts/standards/runbooks to the product codex, not the `Documentation/`
  tree.** When the track is ambiguous, ask.
- **On "promote/merge/roll into master" or "rollup/cleanup,"** run the five-step procedure in §11
  (locate branch → squash to one ff-able commit and check its content → `--ff-only` merge, or a
  guarded `update-ref` on a held tree → **confirm before deleting** the branch → **reconcile the
  relevant backlog item(s)**: surface & confirm a status update, typically `Implemented` —
  `rollup.reconcile_backlog`). Hotfixes go through the trunk. Never commit on `master`, never
  `--no-ff`, never force-push a protected ref, never push a protected ref yourself, and never
  auto-edit a backlog item.
- **Cut an RC only on the operator's explicit instruction — never proactively**
  (`release.rc_requires_explicit_instruction=true`). An RC is **never** a side effect of a
  "rollup"/"cleanup" (which is commit → promote-to-`master` → delete-branch → reconcile-backlog only), a
  release sweep, a fleet audit, or a drift signal — those mean *surface it and ask*, not cut. If unsure,
  ask first.
- **On "promote to staging / cut a release candidate" (explicitly asked),** run the cut-RC procedure
  in §11 for `staging-soak` repos only (drain outstanding branches into `master` first, per-branch
  confirm → pick the candidate repos → compute the next `-rcN` **per repo** → reset
  `release/staging` to `master` and tag locally, signed if the resolved `release.sign_tags` is on →
  **hand the operator the push commands**; the agent does not push → reconcile `STATUS.md`). Stop if
  a soaking candidate would be lost. Never create `release/staging` to make a cut possible.
- **On "promote to production / ship it,"** run the promote-to-production procedure in §11 for a
  `staging-soak` repo (confirm the soaked candidate → verify the gates: no open Blockers,
  no-regression, **and the release-notes gate where the resolved policy turns it on and the version
  is in scope** → roll `release/previous` forward → ff-only advance `release/current` + tag locally →
  **hand the operator the push commands** → reconcile `STATUS.md`). If a gated release lacks notes,
  STOP — author the notes through the normal branch→master→candidate path; never patch them onto a
  protected branch to pass the gate. For a `rolling-pair` repo run its shorter promote (§11:
  operator-named version → preflight → rotate, ff, tag locally → hand back the push).
- **Where the resolved `release.sign_tags` is `true`, sign the RC and production tags, and confirm
  the signature landed.** The tag is the **only** signable artifact at the release boundary — both
  the cut and the promote move a ref to an existing SHA and author no commit — so consumers verify
  with `git verify-tag`, **never** `git verify-commit`. **Signing is verified, not assumed:**
  `git tag -a` with an unloadable key exits 0 and creates an *unsigned* tag, so check the object
  carries a signature and delete it if not. No key resolved (`CANON_RELEASE_SIGNING_KEY`, else
  `canon.releaseSigningKey`) means **stop and surface** — never cut unsigned, and roll back any ref
  you already moved.
- **"Generate / update release notes" for a multi-repo product means draft only** (§11, the release
  console): `release-delta --product` → translate for users → `release-notes-save` → stop. Stamping
  (`release-stamp --product --component repo=ver`) is the operator's separate act.
- **Before deleting anything, surface it and get explicit confirmation** (§11, "Deleting files").
  Deletion is allowed but always confirmed; deleting *history/outcomes* is forbidden (archive
  instead). Prefer `git rm` for tracked files. **Never** refuse-and-improvise or route around a
  blocked delete with a `git worktree`/`reset`/`checkout`/temp-index/**`mv`-clobber** workaround — a
  move that overwrites or displaces an existing path is a delete, `git worktree remove`/`prune`/`move`
  are deletes, and a deny means *ask*, then re-run with `CANON_CONFIRM_DELETE=1` once approved.
- **In Cowork, `Operation not permitted` on a delete (or a git commit/merge/lock-cleanup that must
  unlink) means call `allow_cowork_file_delete` and proceed — not "I'm blocked."** Request the
  permission the instant you see EPERM on a removal; never tell the operator the operation is
  impossible. If you think you can't delete/commit/merge, you're wrong — ask for the permission.
- **Leave no orphans** (§11, "Leave no orphans"). A promote/cut-RC/delete isn't done until the repo is
  verified clean: tree clean, no stale `*.lock`, no `tmp_obj_*` cruft, no leftover `promote/*` or
  scaffold branch the agent made, source branch deleted per confirm, target ref exactly as intended,
  **the commit's content verified** (tree not empty, `git diff --name-only HEAD~1 HEAD` exactly what
  you meant), and the **lease released** (HEAD parked only if instructed). On failure, **roll
  back to the pre-op state** (`--abort`, drop temp branch, clear locks) — never report success with
  residue, never leave the operator a mess to clean up by hand.

---

## When you need org or product specifics

This skill stops at the universal model. For an org's roster, identities, host, overlay or
org-only skills, read the org governance repo (L1). For a product's workspace/service map, its
consumed contracts, its release-notes plumbing, or its repo-tier wiring, the repo-tier skill
(`governance-fe` / `governance-be`) carries those and preloads this skill. If a task needs a detail
this skill deliberately omits, that's the signal to consult the tier below.
