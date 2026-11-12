---
name: backlog-intake
description: Capture and triage raw signal into a governed repo's backlog (one file per item under Backlog/, indexed by BACKLOG.md), with first-class handling for staging / release-candidate testing feedback. Use whenever someone says "add this to the backlog", "capture this", "log a bug / feedback / idea", "found in staging", "triage the backlog", or pastes tester/QA findings from a release-candidate soak. Produces backlog items in the org's id form (and, for RC-soak findings, paired RC-remediation lane entries) and routes each item per the governance funnel. Source-agnostic — it works the same whether the feedback is typed in chat now or fed from an ingestion adapter later. Preloads governance-core for the funnel/lifecycle model; the repo-tier skill (governance-fe / governance-be) names the board path and app/service map.
---

# Backlog intake — capture & triage

This skill makes capturing signal into a governed repo's backlog (`Documentation/Backlog/` items,
indexed by `Documentation/BACKLOG.md`) **low-friction and consistent**, so testing feedback (and any
other raw signal) lands in the governance model instead of a chat thread. It implements the front of
the funnel defined in `governance-core` §1; it does not restate that model, it operationalizes it.

**Trigger phrasing** (non-exhaustive): "add this to the backlog", "capture this", "log a bug",
"file this", "found in staging / in rc<N>", "triage these", or a pasted batch of QA/tester notes.

> Source-agnostic by design. Today the input may be the user typing findings; later it may be a chat
> channel, an issue tracker, or a test-run report. The procedure below is the same regardless of
> where the raw text came from — only the *ingestion* changes, never the capture/triage rules.
>
> **Ingestion adapters** fill that seam: a thin skill reads one external source (a capture inbox, a
> chat channel, an issue tracker), normalizes its items, and feeds this funnel without restating these
> rules. Canon ships one engine, `obsidian-ingest` (a repo-free Obsidian capture inbox, configured per
> org); an org may add further adapters as L1 skills the same way when such a source is connected, and
> each routes into the procedure below unchanged. The org governance repo lists which adapters it
> runs.

---

## 1. Pick the board (repo tier)

Capture into the backlog of the governed repo the item belongs to — the governed repos are listed in
the org roster `org-governance/fleet/repos.json` (resolve through it; never glob the workspace
folder). Each roster entry's board lives under that repo's documentation directory (`Documentation/`
unless the roster's `docDir` says otherwise); the repo-tier skill (`governance-fe` /
`governance-be`) names the exact path and the app/service map that tells you which repo owns a
problem. Framework-tier signal (about the standards, shared skills or enforcement) goes to the **org
governance track** at `org-governance/Documentation/` instead (`governance-core` §1).

Ids follow the org's **`ids.form`** (`standards/terminology.md`; `governance-core` §1): `qualified`
(bare `BL-NNNN` inside the repo, `<repo> BL-NNNN` when cited from another) or `prefixed`
(`<PRODUCT>-BL-NNNN` everywhere). Below, `BL-NNNN` stands for whichever form the org uses.

If a report belongs to a different repo than the one it surfaced in (a frontend report that is really
backend work, or vice versa), capture it on the **reporting** repo's board so the signal isn't lost,
then route it with Disposition **→ other-repo backlog** and open the mirror item on the owning board.
Neither side dangles (`governance-core` §1).

---

## 2. Capture — write the item

1. **Take the next id.** It is one more than the highest id already present under `Backlog/` (and in
   the generated index) for that board — four-digit, sequential, immutable once assigned. Never reuse
   or renumber, and never reuse an id that appears in history even if its file has moved.
2. **Create the item file** `Backlog/BL-NNNN-<slug>.md` from the board's item template (seeded from
   canon `templates/backlog-item.md`). Fill the frontmatter: `id`, `title` (one line), **`type`**
   (Feature · Bug · Design-idea · Code-review · Tech-debt), `status: New`, `horizon: someday`,
   `reporter`, `opened` / `updated` (today), and `severity` / `found_in` where relevant. Put the
   reporter's words, repro steps, sketches or traces in the body; seed `## Log` with a capture line.
3. **Don't reach for a SOW.** A backlog item has no DoD and no behavior-verb requirement — it is a
   note that *might* become work.
4. **Regenerate the index** — `canon-index index <Documentation-dir>` — in the same edit. Never
   hand-edit the generated block of `BACKLOG.md`.

**Batch capture:** when handed many findings at once, create one item per distinct issue. Collapse
obvious duplicates into a single item (note the dupes); do not invent severity or repro the reporter
didn't give — capture what was reported and flag gaps at triage.

---

## 3. Staging / RC testing feedback (the RC-remediation lane)

Feedback found while testing an active **release candidate** gets the same backlog item **plus** an
entry in the board's **`## RC Remediation — <active rc tag>`** lane, because it has release-blocking
implications the general backlog does not track.

For each RC-soak finding:

1. Capture the item as in §2, `type` usually `Bug`, with **`found_in: <vX.Y.Z-rcN>`**.
2. **Add a paired RC-remediation entry** with a **Severity** call:
   - **Blocker** — the RC must not ship to production until this is fixed.
   - **Major / Minor** — should be fixed but is not release-blocking; may be deferred.
3. **Route by severity:**
   - **Blocker / Major-to-fix-now** → fix on a **`bugfix/*` branch off the trunk** (never commit on
     `release/staging`, and never branch off it — an RC cut resets `release/staging` to the trunk, so
     a fix made off the candidate is discarded by the next cut). Promote it to the trunk by the
     `governance-core` §11 procedure; the candidate is then **re-cut at `-rcN+1`**. Set the lane
     Status to `In-fix`, then `Fixed (rc<N+1>)` once it lands and the candidate is re-cut.
     (`standards/git-branch-roles.md`, the hotfix rule; there is no `stabilization/*` branch type.)
   - **Deferred** → leave it in the backlog for normal triage (Disposition **→ SOW** or
     **folded into <slug>** when scheduled); set the lane Status `Deferred (→ backlog)`.
4. **The RC promotes to production only when every Blocker in its lane is `Fixed`.** This is the
   capture-side companion to the no-regression gate (`governance-core` §11).

**RC-remediation lane row shape:**

```
| BL | Severity | Found in | Item | Status | Fix (bugfix branch / PR → rc) |
|----|----------|----------|------|--------|-------------------------------|
```

Severity ∈ {Blocker · Major · Minor}. Status ∈ {Open · In-fix · Fixed (rc<N>) · Deferred (→backlog/SOW)}.

### Environment / config findings (cutover-impacting)

Some soak findings are **not code** — they are deployment/configuration facts: an empty/wrong path, a
missing or wrong service/datastore/secret config, a missing migration, a wrong host/target. These
recur at **prod cutover** unless they are captured for the rollout, and the prod window is far shorter
than the staging soak. Tag them so they can be harvested:

- Add the class **`env/config`** to the finding (in the item's frontmatter or body), distinct from a
  code bug.
- Add **`cutover-impacting: yes`** when prod will hit the same thing (usually, since staging and prod
  share the same deployment shape with *different* hosts/secrets — see the repo-tier
  deployment-topology invariant). Use `no` only for a staging-only artifact.
- These still get their normal Severity + RC-lane entry and usually resolve via a config/migration fix
  on a `bugfix/*` branch off the trunk, re-cut as `-rcN+1` like any other Blocker — but the **fact and
  its fix must also reach the cutover runbook**.
- Whoever owns the release (a release agent, where the org deploys one) **harvests every
  `cutover-impacting` finding** into the cutover runbook's **staging↔prod delta ledger** (*what we hit
  → the fix → the prod equivalent*) and the prod pre-flight checklist. Capturing the tag is what makes
  that harvest possible; don't bury an env/config stumble as a plain Bug.

---

## 4. Triage — assign a Disposition

Triage is periodic; items don't sit in `New` indefinitely. At triage, set Status `New → Triaged`,
set `horizon` (`now` / `next` / `someday`) and `big_idea` where it applies, and assign a
**Disposition** (`governance-core` §1): **→ SOW `<slug>`** · **folded into `<slug>`** ·
**→ hotfix `<branch/PR>`** · **→ other-repo backlog** · **→ governance intake track** ·
**won't-fix (`<reason>`)** · **duplicate of `BL-NNNN`** · **quick-fix done (`<commit/PR>`)**. When
promoted or folded, the target SOW's Lineage cites the `BL` id and the item's Disposition links the
SOW — lineage closes both ways. Later states follow `governance-core` §1: `Active` when a SOW/CR is
opened, `Implemented` when the change is built and on the trunk but not yet in production (or, for a
doc-only change, landed but not fully propagated), `Closed` when it is verified where users run.

**A backlog item is never required to become a SOW.** Declining (won't-fix / duplicate) is a valid,
recorded outcome — the point is that the decision is captured.

---

## 5. After capture — keep the chain honest

- Regenerate the index (`canon-index index`) in the **same edit** as adding or changing an item, and
  add a `## Log` line to the item for every status change.
- If a captured item changes a SOW's scope or a dashboard state, update those in the same session
  (`governance-core` §5, §8 — same-session sync; keep `STATUS.md` current).
- Capturing is a `Documentation/`-tree edit: it follows the repo's git flow (a working branch, not a
  direct commit on `master`/`release/*`). Batch a capture session into one clean commit.

---

## Quick reference

- "Add this to the backlog" → §2: next id, new `Backlog/BL-NNNN-<slug>.md`, `status: New`, regenerate
  the index.
- "Found in staging / rc<N>" → §2 + §3: item with `found_in:` **and** an RC-remediation entry with a
  Severity; route Blockers to a `bugfix/*` branch off the trunk, then re-cut the candidate.
- "Triage these" → §4: Disposition + Status `Triaged`/`Active`/`Implemented`/`Closed`, lineage both ways.
- Unsure which repo? Capture on the reporting board, route **→ other-repo backlog**, mirror the item.
- About the framework itself? → the org governance track, not a product board.
