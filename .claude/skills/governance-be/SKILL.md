---
name: governance-be
description: Sunergeo backend repo-tier governance — the service map, multi-service SOW coordination, the codex contract discipline, release-notes ownership, the deployment-topology invariant, and ADR namespacing for Sunergeo backend repos. TEMPLATE — no Sunergeo backend repo is bound yet; this activates when one is onboarded (e.g. an AgriTag premium-sync API or a Syntropium service). Use it when working in a governed backend repo's Documentation/ tree or its service trees: writing a SOW or engineering plan that touches a service, planning a change to a wire contract / event schema / service API, doing a backend code review or audit, deciding whether a doc is SOW-track or codex-track, or producing a staging/prod procedure. Triggers on "backend", "services repo", "multi-service SOW", "per-service engineering plan", "codex contract", "API/event schema", "release notes ownership", "deployment topology". Preloads governance-core for the universal meta-model — do not restate those rules; this skill adds only backend specifics.
---

# Governance BE — Sunergeo backend repo tier (template)

This is the **repo tier** for Sunergeo **backend** repos. It composes on top of `governance-core`:
the universal outcome-centric meta-model, SOW rules, lifecycle, lineage, `STATUS.md` discipline, and
git/release standards all come from there and are **not restated here**. This skill adds only what is
specific to a backend codebase.

> **Status: template, unbound.** No repo in `org-governance/fleet/repos.json` is `tier: be` today.
> When a Sunergeo backend is onboarded, bind the placeholders below (the service map, the topology,
> the release-notes owner, the codex location) to that repo's reality and add its `fleets.<repo>`
> block to `manifest.json`. Until then this skill is the reusable shape, not a live binding.

**Always operate `governance-core` + this skill together.** If a rule is about the *shape* of the
workflow, it's in core. If it's about *which service*, *which contract*, *the codex*, *release-notes
ownership*, or *host topology*, it's here.

---

## 1. Scope — what this governs, and what it does NOT

This skill governs **SOW-track work** under the backend repo's `Documentation/` tree: the intake
backlog, SOWs, the active-work expansion (Architecture / Engineering / Review and Remediation), the
ADR registry, the status dashboard, and the archive.

It does **NOT** govern **permanent engineering / operations / architecture / standards
documentation** — that is **codex-track** and lives in the repo's dev codex (bind its path at
onboarding; e.g. a `Documentation/standards/` tree or a dedicated docs service). The codex is the
single source of truth for wire contracts and platform standards.

**Rule of thumb:**
- A doc under `Documentation/` (an outcome, a plan, a review) → SOW-track, this skill governs it.
- A permanent contract, ops/CI-CD runbook, architecture reference, or platform standard → codex-track.
- **If unsure which track applies, ask before writing.**

---

## 2. The backend service map (bind at onboarding)

A backend repo may be a **single service** or a **multi-service monorepo**. SOWs are **repo-level**:
one outcome may touch one service or several. Replace this placeholder with the real services when a
backend is onboarded:

| Service / area | Role |
|---|---|
| `<service-a>` | _(bind: e.g. core API; owns the release-notes channel)_ |
| `<service-b>` | _(bind: e.g. gateway / auth boundary)_ |
| `<shared>` | _(bind: shared libs, schemas, infra)_ |

**Invariants:**
- The wire contracts / event schemas published in the codex **are the contract**; services conform
  to them. A SOW that changes a consumed contract coordinates updates across **every** affected
  service (per `governance-core` multi-repo coordination).
- The **deployment-topology invariant (§5)** is repo-wide once bound.

---

## 3. Multi-service SOW coordination

When a SOW spans services, `Engineering/` holds **one plan per service**
(`<slug>-<service>-engineering-plan.md`), each citing the SOW and the shared architecture doc, so
cross-service dependencies are visible in one place. The SOW lists service scope explicitly (in and
out) and tracks per-service status in its acceptance criteria. A contract/schema change requires an
Architecture doc defining the new shape and migration, one Engineering plan per affected service, the
codex contract updated in the same SOW, and a data migration story — a SOW proposing such a change
without coordinated plans **is not ready to start**.

## 4. Feature flags

Per `governance-core` §11: each outcome-SOW gets a tightly-scoped flag from day one so it ships
independently. A SOW that can't be flagged says **"No flag"** with the reason.

## 5. Deployment-topology invariant (bind at onboarding)

Backends usually split trust/state across hosts (separate VMs, containers, managed datastores, or
serverless boundaries). **Bind the real topology here at onboarding** and make it a hard, repo-wide
rule: every staging/prod procedure is **host-labeled**, and a credential/datastore that must live on
one host is never reachable from another. The security/data-modeling specialists enforce this once
bound. (For a small managed-platform backend, the "topology" may simply be "the managed DB and the
secret store are separate from the app runtime" — still state it explicitly.)

## 6. Releases and release-notes ownership

Release mechanics (coupling test, the mandatory no-regression gate) are universal — see
`governance-core` §11. **Bind the release-notes owner** at onboarding: in a multi-service backend one
service typically owns the user-facing `release_notes` channel and other services/clients supply
user-oriented lines for their visible changes. Write notes for users, not engineers; finalize before
prod cutover.

## 7. BE code review — codex conformance (adds to core §10)

Follow the lineage-grounded reading order in `governance-core` §10. For a backend, **step 5** is the
codex contracts the change must conform to (`standards/`, the owning `apis/<api>/` and
`events/<event>/` contracts). Contract drift is the most common source of backend bugs — confirm the
plan still matches the codex before building/reviewing. When the codex itself is stale, that's a
codex-track issue — raise it; don't patch around it. If any required upstream doc is missing, STOP
and report the gap.

## 8. BE-specific reminders

- **SOWs are repo-level**; per-service work goes in the outcome's `Engineering/` with per-service
  filenames (§3).
- **Honor the deployment-topology invariant** in every environment procedure (§5).
- **Conform to the codex, and check it's current** (§7).
- **Bind and respect the release-notes owner** (§6).
- Everything else — SOW validity, status, lifecycle, lineage, `STATUS.md` sync, git/branch/release —
  comes from `governance-core`. Apply both together.

## 9. Specialist fleet (org-tier catalog, BE selection)

A backend repo typically selects `domain-security`, `domain-performance` (bound to query/fan-out
cost), and `domain-data-modeling` from the org-tier catalog, plus a generalist `<repo>-auditor`.
Selection is recorded in `manifest.json` once the repo is onboarded.

## 10. Stewards (per-service deep experts) — when applicable

For a **multi-service** backend, a per-service **steward** (`<repo>-<service>-steward`) brings deep
knowledge of one service and composes the relevant craft lenses through it (its knowledge source is
the service's codex docs + code + its own memory file, never a duplicated skill). Declare stewards
under `fleets.<repo>.serviceExperts` in `manifest.json`. A single-service backend does not need
stewards. See `org-governance/fleet/README.md` for the specialist-vs-steward distinction.
