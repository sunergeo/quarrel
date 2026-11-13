---
id: BL-0008
title: "Optional lesson: Huffman coding and a small inflate (DEFLATE) decoder, kept outside the shipping path"
type: Process-idea
status: Triaged
horizon: someday
big_idea: null
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: crates/quarrel-lessons (module compression); dev-dependency flate2
disposition: null
---

# BL-0008 — Optional lesson: Huffman coding and an inflate decoder

## Shapes

**quarrel-shipper**: gzip on every OTLP batch (ADR-0007 §1) and reading gzip-rotated files (M3).
Module `compression` in `crates/quarrel-lessons`.

## Math it exercises

prefix codes and trees; a greedy algorithm and its optimality proof; entropy H = −Σ p·log₂ p; the Kraft inequality Σ 2^(−ℓᵢ) ≤ 1.

## Why

SB, 2026-11-13: Huffman coding is something he has long wanted to learn. The shipper gzips its OTLP
batches (ADR-0007 §1) and will read gzip-rotated files (M3), always through `flate2`, never through
hand-written code (ADR-0006 §1: learning never lowers the bar). This lesson is where the format
gets learned, beside the product, not inside it.

## Rules

- **Optional, and never on the shipping path.** No production code calls it. It is not a gate for
  any SOW.
- **Tested like everything else.** Unit tests and doc tests; every decoded stream is checked
  byte-for-byte against `flate2` (a dev-dependency only).
- **Clean-room, from the specs:** RFC 1951 (DEFLATE) and RFC 1952 (gzip), as ADR-0003 §6 does for
  the probe. Cite sections in the code.

## Steps (each one small, tested, and useful on its own)

1. **Huffman coding from first principles.** Build a code from symbol frequencies (the classic
   tree), then the *canonical* form DEFLATE uses: codes rebuilt from code lengths alone (RFC 1951
   §3.2.2). Encode and decode round-trip tests.
2. **A bit reader.** DEFLATE packs bits least-significant first, but Huffman codes are read
   most-significant first; this is the classic trap.
3. **Stored and fixed-Huffman blocks** (§3.2.4, §3.2.6). Decode `flate2` output at level 0 and for
   short inputs.
4. **LZ77 back-references.** Length/distance pairs and the 32 KiB window, including overlapping
   copies (distance < length, which is how runs are encoded).
5. **Dynamic-Huffman blocks** (§3.2.7): the code-length code, then the literal/length and distance
   codes. Now any `flate2` output decodes.
6. **The gzip wrapper** (RFC 1952): header flags, CRC-32 and ISIZE checks; multi-member files (what
   `cat a.gz b.gz` produces); and what a truncated stream looks like, which is the case the shipper
   will meet when a rotated file is still being compressed.
7. **(Stretch) An encoder:** fixed-Huffman first, then a simple LZ77 matcher. Compare its ratio and
   speed with `flate2`'s levels: the measured trade-off ADR-0007's level choice rests on.

## Placement

Decided 2026-11-13 (SB): all lessons live in `crates/quarrel-lessons`, a workspace member that no
binary depends on, one module per main idea. This one is `compression` (`src/compression/`:
`huffman`, `bits`, `inflate`, `gzip`), with its tests in `tests/compression.rs`.

## Log

- 2026-11-13 — Captured at SB's request; optional, someday.
- 2026-11-13 — Placement decided: `crates/quarrel-lessons`, module `compression`.
