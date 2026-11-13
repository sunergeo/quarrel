---
id: BL-0018
title: "Possible enhancement: native Windows and macOS desktop clients for quarrel-ping"
type: Process-idea
status: New
horizon: someday
big_idea: BI-01
reporter: SB (via Cowork agent)
opened: 2026-11-13
updated: 2026-11-13
affected: ADR-0008 §4; quarrel-ping engine API
disposition: null
---

# BL-0018 — Possible native Windows and macOS clients

## Summary

SB, 2026-11-13: write up a possible future native Windows/macOS client as an enhancement, alongside
the TUI. Not committed. Recorded now so that quarrel-ping's measurement engine is built as a library
with a stable API a GUI could sit on, rather than being welded to the CLI.

## What it would be

- A desktop app for non-technical users (the PingPlotter-like experience): pick a target, watch the
  time graph, see "the problem starts inside <network>", export a report for a ticket or an ISP.
- Built on the same engine as the CLI, OTLP exporter and TUI; no second measurement implementation.
- Shipped separately from the command-line tools.

## Questions for when it is taken up

- Native per platform (SwiftUI on macOS, WinUI on Windows) over a Rust core via FFI, or one
  cross-platform Rust GUI toolkit?
- Privileges: the engine's no-root default (ADR-0003 §2) must hold; installers must not demand admin.
- Distribution and signing: notarised macOS builds, signed Windows installers, update channel.
- Whether users need it at all, or the TUI covers support use.

## Log

- 2026-11-13 — Captured as a possible enhancement.
