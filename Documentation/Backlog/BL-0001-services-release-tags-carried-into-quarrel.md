---
id: BL-0001
title: The extraction from services carried 87 services-release tags into quarrel
type: Process-idea
status: Closed
horizon: now
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-12
updated: 2026-11-12
affected: refs/tags/*
disposition: "Option 1 — deleted locally before the first push (SB, 2026-11-12)"
---

# BL-0001 — Services-release tags carried into quarrel

## Summary

quarrel was extracted from the services repo with its history. The extraction kept 87 tags
(`v0.11.1` … `v0.13.7-rc2`, `jenkins-lib-v1.17.0` … `v1.20.0`), rewritten to point at quarrel's
four argus commits. They name **services** releases; quarrel has never been released
(`releaseModel: trunk-only`).

## Why it matters

Pushed to `git:quarrel`, they would read as quarrel's release history, and tags are create-only on
the server, so they could not be cleanly removed later. Until decided, push `master` only — never
`--tags`.

## Options

1. Delete them locally (confirm-gated) before the first push. Services keeps the originals.
2. Keep them local-only as a record of where each commit came from.

## Log

- 2026-11-12 — Found during onboarding (GOV-CR-0024).
- 2026-11-12 — SB chose option 1: all 87 tags deleted locally before the first push.
