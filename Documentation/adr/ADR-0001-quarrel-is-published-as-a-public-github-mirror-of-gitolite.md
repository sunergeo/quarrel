# ADR-0001 — quarrel is published as a public GitHub mirror of gitolite, dual-licensed MIT OR Apache-2.0

- **Status:** **Accepted 2026-11-12.** `github.com/sunergeo/quarrel` (public) and `git:quarrel` both
  hold `master` = `1e08c94`, pushed origin first. *(Was Proposed until the mirror existed.)*
- **Date:** 2026-11-12
- **Deciders:** SB
- **Scope:** Repo-level. Where quarrel is published, under what license, and which host is
  authoritative.
- **Related:** org `GOV-CR-0024` (onboarding); canon `standards/host-contract.md` §5.2 (GitHub
  adapter: designed, dormant).

## Context

quarrel is governed on the Sunergeo gitolite instance (`git:quarrel`, ecx-gitsb1), where the gate
enforces the branch model: `master` advance-only, undeclared `release/*` refused, the canon VREF on
every push (`verify-gate --server` 71/0, 2026-11-12). SB wants the code public on GitHub as well.

canon's GitHub adapter is designed but dormant: nothing it generates runs, so a GitHub repo is never
reported as gated. A repo whose code is public needs a license; without one it is all rights
reserved.

## Decision

1. **gitolite is the system of record.** `origin = git:quarrel` stays the roster `remote`; the
   funnel, the gate and every promotion happen there.
2. **GitHub is a mirror on a separate remote**, `github = git@github.com:sunergeo/quarrel.git`.
   Push order is always **`origin` first, then `github`**, and `github` only receives what `origin`
   has already accepted. Never a multi-URL `origin`: each push URL is independent, so GitHub would
   accept commits the gate refused. `master`'s upstream is `origin/master`, so a bare `git push`
   or `git pull` goes to gitolite; GitHub is always named explicitly (`git push github master`).
3. **Mirrored refs:** `master`, and once the repo moves to `rolling-pair`, `release/*` and the
   `vX.Y.Z` tags, all after gitolite accepts them. Never `--mirror` or `--all`: working branches
   stay local.
4. **No work lands on GitHub.** No web-UI commits, no merged pull requests. An outside contribution
   is applied locally on a working branch and promoted through gitolite like any other change.
5. **GitHub protection:** ruleset `protect master` (id `27128008`, created 2026-11-12, active) on the
   default branch: `deletion` + `non_fast_forward`, empty bypass list. It is a seatbelt only;
   GitHub is not reported as gated (host-contract §5.2).
6. **License:** `MIT OR Apache-2.0` (the Rust ecosystem convention), `LICENSE-MIT` +
   `LICENSE-APACHE` + `Cargo.toml` `license`, copyright Sunergeo Systems.

## Consequences

- The history is public, including author emails (`sbradley@sunergeosystems.com`,
  `cowork-agent@agents.sunergeo`) and the governance docs under `Documentation/` and `.claude/`.
  The 2026-11-12 pre-publish scan of every commit found no secrets, addresses or hostnames.
- A push to GitHub that fails or lags leaves the mirror stale but never wrong. Re-push from local
  `master`; GitHub never holds anything gitolite lacks.
- If GitHub ever becomes authoritative, or gated, that is a new ADR and an org change (roster
  `remote`, a built GitHub adapter).
