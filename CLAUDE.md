# quarrel — Backend Workflow Governance (thin floor)

> **This file is the always-on floor, not the full rulebook.** It was added when quarrel was brought
> under the **Sunergeo platform governance** (`../sunergeo-platform-governance/`; quarrel is listed in
> `org-governance/fleet/repos.json`, GOV-CR-0024). The complete governance lives in two skills that
> load on demand:
>
> - **`governance-core`** — the universal canon meta-model + git/release standards (framework tier).
> - **`governance-be`** — backend repo specifics (repo tier; preloads `governance-core`).
>
> When you do real governance work in `Documentation/`, `src/` or `tests/`, **consult those skills**.
> The rules below are the subset that must hold **even when no skill has loaded**. This floor is
> **repo-local**: at roster scope there is no quarrel bundle in the platform-governance repo, so it is
> edited here (if quarrel moves to scope full, its source moves there).

quarrel holds **`argus`**, the per-host log shipper: a Rust crate (`Cargo.toml` name `argus`) that
tails log files and ships the raw lines to an ingest endpoint, built as a static musl binary in a
`scratch` image. It is built step by step along a milestone roadmap (M0–M2 shipped, M3 discovery in
progress; see `ROADMAP.md`). Its one invariant: **never save a file offset past what the destination
has acknowledged** — a duplicate is harmless, a skipped line is the only real failure. Server-side
repo name: `git:quarrel`. Governed at **`scope: roster`**, release model **`trunk-only`** (not
deployed yet; packaging and CI are M8). If a request appears to conflict with this workflow,
**surface the conflict before proceeding.**

---

## Always-on hard rules

1. **SOW titles name behaviors, not code.** Behavior-verbs (`deliver`, `ensure`, `enable`, `within`,
   `you can now`); **reject code-verb titles** (`migrate`, `refactor`, `rewrite`, `consolidate`,
   `unify`) — restate as the outcome.
2. **A SOW's Definition of Done is a test against the running shipper** — a runnable scenario
   (`cargo test` plus a scripted run of the binary against real files: restart, rotation, truncation,
   kill -9), not merged commits or a milestone number.
3. **One SOW per outcome.** Search `Outcomes/` (incl. `_archived/`) before drafting; update rather
   than fork.
4. **An outcome folder has exactly three subfolders** — `Architecture/`, `Engineering/`,
   `Review and Remediation/`. No stray folders, no docs at the outcome root except the SOW. The build
   is code in `src/` + `tests/`, not a doc folder.
5. **Capture raw signal in the backlog first** (`Documentation/Backlog/BL-NNNN-<slug>.md`, index
   regenerated into `BACKLOG.md`), not as a premature SOW.
6. **SOW Status is explicit and never inferred from folder location**; log transitions in the SOW.
7. **Keep the chain in sync, same session** (downstream doc → SOW; Status/ADR → `STATUS.md`).
8. **Every downstream doc cites its lineage**; require a SOW reference — no orphan docs.
9. **Code reviews are lineage-grounded** — read SOW → Architecture → all Engineering plans → prior
   Reviews → then the code; if any upstream doc is missing, STOP and report the gap
   (`governance-core` §10). No dedicated auditor exists at roster scope.
10. **Never delete history** — archive to `Outcomes/_archived/<slug>/` (flattened) on a passing DoD.
11. **All real logic lives in `src/lib.rs` and its modules**; `src/main.rs` stays a thin shell, so
    tests can reach everything. `Cargo.lock` is committed; the Docker build runs `--locked`.
12. **Git/branch/release discipline applies** — integration trunk **`master`**, `--ff-only` merges,
    one clean commit per feature, no merge commits, feature branches deleted after merge. See
    `governance-core` §11.
13. **"Promote/merge/roll into master"** → the §11 promote procedure (working branch → squash to one
    ff-able commit → `--ff-only` merge → ask before deleting the branch). Never commit/edit on
    `master`; never `--no-ff`; never force-push a protected ref.
14. **Release model is `trunk-only`.** There are no release refs yet. Moving to `rolling-pair` when
    argus is first deployed is a §11 governed operation (ADR + refs + roster in one effort).
    **Do not push `--tags`**: the repo carries services-release tags from the extraction (BL-0001).
15. **Deletion is always confirmed; never route around a block.** In Cowork, `Operation not
    permitted`/EPERM on a delete (or a git step that must unlink) means call
    `allow_cowork_file_delete`, then proceed. Deleting history/outcomes is forbidden — archive instead.
16. **Start on a working branch — proactively.** If HEAD is `master`/`release/*`,
    `git switch -c feature/<slug>` first. "What branch am I on?" is the first question.
17. **One writer per working tree** — claim the lease (`git rev-parse --git-path
    canon-worktree.lease`) and, in Cowork, check `session_info`, before switching HEAD or editing.
18. **Leave no orphans** — every promote/delete ends verified-clean, or roll back to the pre-op state.

(Full text for 13–18 is authored once in `governance-core` §11 — link, don't re-encode.)

---

Layout: see `README.md` (`src/`, `tests/`, `examples/`, `Dockerfile`, `docker-compose.yml`). SOWs are
**repo-level**. Funnel: `Documentation/` (`STATUS.md` → `Outcomes/` → `ROADMAP.md` → `BACKLOG.md`).
