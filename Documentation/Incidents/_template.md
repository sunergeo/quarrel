---
id: INC-NNNN                 # immutable, matches filename stem
title: <one-line title>      # plain text, no markdown
severity: Sev-2              # Sev-1 (total/critical) | Sev-2 (major) | Sev-3 (minor)
status: Investigating        # Investigating | Mitigated | Resolved
started: YYYY-MM-DD          # when user impact began
detected: YYYY-MM-DD         # when it was first noticed
resolved: null               # YYYY-MM-DD when user impact ended
duration: null               # user-impact duration, e.g. ~1h5m
impact: <scope + who was affected>
detected_by: <how it was noticed — and whether an automated alert fired (the detection gap)>
components: <comma list of affected components>   # legacy field name `services` is still read
related: <backlog / change-record ids, comma-separated, in the org's id form>
commander: <who ran the incident>
opened: YYYY-MM-DD
updated: YYYY-MM-DD
---

# INC-NNNN — <one-line title>

> One incident per file. The frontmatter above is the machine-read record; the board's
> **Incidents** tab and any generated index read it. Incidents live with the product they affect
> (the product's first member repo, unless its `products.json` entry names another
> `incidents.location`); incidents about the governance process itself live on the org track.
> Copy this file to `Incidents/INC-NNNN-<slug>.md`, fill in the frontmatter + body, and delete these
> guidance blockquotes. Trigger bar: any full outage, or user-facing degradation over ~15 minutes,
> gets a record.

## Summary

<Two or three plain sentences: what broke, who was affected, how long.>

## Timeline

<Dated/timestamped steps: onset → detection → diagnosis → mitigation → resolution.>

## Impact

<Scope (which users / tenants / surfaces), severity, and duration.>

## Root cause

<The actual cause, stated plainly.>

## Contributing factors

<What made it worse, slower to detect, or harder to fix.>

## Detection gap

<How it was detected and whether an automated alert should have fired. Required — the recurring
failure mode is "a human noticed before the system did.">

## Remediation

<Follow-up items, each linked to its backlog id.>

## Lessons

<What changes so this class of failure is prevented or caught automatically next time.>

## Log

- YYYY-MM-DD — record opened.
