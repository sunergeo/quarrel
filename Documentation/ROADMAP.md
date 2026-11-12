# quarrel — Roadmap

Forward-looking intent, grouped **Now · Next · Later** (`governance-core` §1). What we intend to do
and roughly in what order — **not** status, not dates. [`STATUS.md`](./STATUS.md) is the source of
truth; if the two disagree, `STATUS.md` wins. Every line traces to a SOW or a `BL-NNNN`; shipped
work leaves this file.

Milestones (M0–M8) are argus's learning roadmap, carried over from the services repo. Shipped before
onboarding: M0 scaffold, M1 `scan`/`tail`, M2 persisted offsets.

## Now

- **M3 — discovery.** Step 1 landed (`fingerprint`: a file's identity by the sha256 of its first
  bytes, `d84c729`). Next: key offsets by fingerprint, survive rename/rotation, and stop exiting on
  a missing file (`BL-0002`). Needs a SOW before more code.

## Next

- **M4 — truncation.** A truncated file currently goes silent.

## Later

- **M8 — packaging and CI.** First deployment; the release model moves `trunk-only` → `rolling-pair`
  then (§11 governed operation).
