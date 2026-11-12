# Quarrel brand specification

Version 1.0 · November 12, 2026 · Website and documentation

[Approved visual reference](./quarrel-brand-board.png)

## Positioning

**Quarrel** is an open-source Rust toolkit for host-side observability. It starts with a command-line tool that reads host logs. The project plans to add active network measurement and a shared event model so operators can correlate what software reported with what the network did.

- **Audience** — Systems engineers, operators, and contributors working from a terminal.
- **Tagline** — Read the host. Measure the path.
- **Short description** — Open-source observability tools for the command line, built in Rust.
- **Name** — Use **Quarrel** in prose and page titles. Use lowercase for the repository, workspace, executable and crate identifiers. Typeset those identifiers as code.
- **Product names** — `quarrel-shipper`, `quarrel-probe`, and `quarrel-core`. The toolkit has one visual identity. Use the full crate name to identify a tool in navigation, headings, and examples.

### Feature claims

| Name | How to describe it today |
| --- | --- |
| `quarrel-shipper` | In development. Scans and tails complete log lines, reports byte offsets, and can persist offsets across runs. File fingerprinting has begun. |
| `quarrel-probe` | Planned active measurement of latency, jitter, packet loss, and network paths. The MTR-style measurement model is proposed. |
| `quarrel-core` | Planned shared event model, state, buffering, and outputs. |
| Open formats | NDJSON, OTLP, and optional Prometheus exposition are design direction. Label them as planned wherever they appear. |

The shipper's design goal is to advance its saved offset only after downstream acknowledgement. Describe that as a design invariant. The current CLI demonstrates local scan, tail, and state behavior. Confirm current capabilities against the repository status, roadmap, and CLI before publishing.

## Logo

### Primary wordmark

The open rounded-square emblem **is the Q**. Set **uarrel** immediately after it to make one word. Use a clean grotesk with a single-storey **a**, tight optical spacing, and the type baseline aligned with the Q body. Preserve the wordmark as fixed artwork across type and layout changes.

The Q's diagonal is a crossbow bolt slanting down and right. It has a straight, slender shaft with enough weight to read against the Q, two short swept feather vanes, and a compact pointed head. The tip breaks a horizontal ground line. In the wordmark, the line starts beneath the arrow and runs continuously to the right edge of the final **l**. Leave a small gap between the lettering and the line. Preserve the bolder bolt proportions in the approved board.

### Standalone mark

Use the Q with its short ground line for favicons, avatars, small documentation navigation, and terminal or social graphics. Retain the arrow silhouette in monochrome. Use the short line for the isolated Q and the extended line for the complete wordmark.

| Surface | Q, wordmark and ground line | Bolt |
| --- | --- | --- |
| Ink | Chalk | Lime |
| Chalk | Ink | Signal Blue |
| Signal Blue | Chalk | Lime |
| Monochrome | Ink on light, Chalk on dark | Same as Q |

### Placement and production

- Reserve clear space of at least one Q stroke width on all sides, measured from the outermost artwork, including the extended line.
- Start with a 180 CSS px minimum for the full wordmark and 32 CSS px for the detailed standalone mark. These are proposed handoff sizes. Verify them against exported assets at actual display size.
- For a 16 px favicon, make a small-size version with simplified feather detail and check that the diagonal, Q opening, and impact line remain distinct. Export a separate 32 px favicon as well.
- Preserve aspect ratio. Keep the mark flat and use solid or quiet backgrounds. Paper grain belongs to presentation surfaces.
- A linked home logo should have the accessible name **Quarrel home**. When visible text already supplies the name, use empty alternative text on the accompanying mark.
- The approved PNG is a visual master for the direction. Prepare clean transparent raster exports of the full wordmark and isolated Q in light, dark, and monochrome at 1× and 2×, plus the favicon sizes. Match the current board when creating these assets. Earlier explorations predate the integrated wordmark.

## Color

Use these values as solid CSS colors. The board's texture and lighting are presentation effects.

| Color | Hex | Role |
| --- | --- | --- |
| Ink | `#161B2D` | Main foreground on light, dark surfaces, terminal background |
| Chalk | `#F4F2EA` | Light page background, main foreground on dark |
| Signal Blue | `#3545D8` | Light-theme links, primary action fill, featured brand panel |
| Lime | `#D9F36D` | Dark-theme links and accents, bolt on dark and blue |
| Slate | `#4D5771` | Supporting text on Chalk |
| Mist | `#C0C8DF` | Supporting text on Ink |

**Text pairs** — Ink on Chalk is 15.25:1, Signal Blue on Chalk 6.26:1, Chalk on Signal Blue 6.26:1, Ink on Lime 13.83:1, Slate on Chalk 6.42:1, and Mist on Ink 10.23:1. Keep Lime for Ink or Signal Blue surfaces. Use a Lime focus outline on Ink or Signal Blue and a Signal Blue outline on Chalk. Use Chalk or Lime for text on Ink. Underline links in prose and pair status colors with words such as **In development**, **Planned**, or **Proposed**.

```css
:root {
  --q-ink: #161b2d;
  --q-chalk: #f4f2ea;
  --q-blue: #3545d8;
  --q-lime: #d9f36d;
  --q-slate: #4d5771;
  --q-mist: #c0c8df;

  --q-bg: var(--q-chalk);
  --q-text: var(--q-ink);
  --q-muted: var(--q-slate);
  --q-link: var(--q-blue);
  --q-focus: var(--q-blue);
  --q-action-bg: var(--q-blue);
  --q-action-text: var(--q-chalk);
  --q-code-bg: var(--q-ink);
  --q-code-text: var(--q-chalk);

  --q-sans: Geist, system-ui, sans-serif;
  --q-mono: "IBM Plex Mono", ui-monospace, monospace;
}

[data-theme="dark"] {
  --q-bg: var(--q-ink);
  --q-text: var(--q-chalk);
  --q-muted: var(--q-mist);
  --q-link: var(--q-lime);
  --q-focus: var(--q-lime);
  --q-action-bg: var(--q-lime);
  --q-action-text: var(--q-ink);
}
```

## Typography and layout

Use **Geist** for display type, headings, interface text, and prose. Use **IBM Plex Mono** for commands, code, output, technical labels, and numeric specimens. These are implementation families for the web and docs. The approved board establishes the visual direction for the custom wordmark.

| Role | Size / line height | Weight |
| --- | --- | --- |
| Homepage headline | 40–72 px / 1.05 | 650–700 |
| Documentation page title | 32–48 px / 1.12 | 650–700 |
| Section heading | 24–32 px / 1.2 | 600 |
| Prose | 16–18 px / 1.6 | 400 |
| Labels | 13–14 px / 1.4 | 500 |
| Code and terminal | 14–16 px / 1.55 | 400 |

Use sentence case in headings and navigation. Reserve tracked uppercase for brief visual labels. Use a 4 px spacing base with 8, 16, 24, 32, 48, and 64 px as the main layout steps. Cap the marketing content width around 1200 px and documentation prose around 68 characters per line. Use slim rules, strong alignment, and generous margins. On narrow screens, stack feature sections and let code blocks scroll independently.

## Website

| Region | Content and treatment |
| --- | --- |
| Header | Quarrel wordmark, Docs, Roadmap, and Source. Collapse navigation on small screens and keep labels available to keyboard users. |
| Hero | Ink background, Chalk wordmark, and **Read the host. Measure the path.** Use a short description and a clear primary action, **Read the docs**. Use **View source** as the secondary action. |
| Toolkit | Put the working shipper first. Label the probe and shared core as planned. Link each item to its docs or roadmap entry. |
| Terminal specimen | Show a real command with short illustrative output on Ink. Use Chalk output and Lime accents. Include a caption when the output depends on sample input. |
| Project links | Source, roadmap, contribution guidance, and the repository's MIT OR Apache-2.0 license. |

Suggested hero body copy:

> Quarrel is an open-source Rust toolkit for host-side observability. Start by scanning and tailing local logs with `quarrel-shipper`. Active network measurement is on the roadmap.

Use the standalone Q on Signal Blue for a feature panel or social preview. For diagrams, use named hops, labelled paths, and units. Keep decorative texture subtle and away from body copy and code.

## Documentation

- **Navigation** — Start with Overview, Quickstart, Shipper, and Roadmap. Add Probe and Core references as the features and their contracts land. Put build prerequisites and platform notes near the commands they affect.
- **Page structure** — Begin with the task or behavior, then show prerequisites, steps, expected output, and related pages. Use descriptive anchors and code fences with a language hint.
- **Examples** — Make commands copyable. Keep shell prompts and illustrative output outside the copy payload. Name the current working directory and any required inputs.
- **Technical language** — State units, measurement location, and the scope of each guarantee. Prefer “byte offset” to “line number” for shipper output. When the probe ships, name the target, vantage point, and measurement window in examples that report latency or loss.
- **Voice** — Direct, specific, and calm. Start procedural headings with verbs such as “Scan a log file” or “Resume tailing from saved state.” Qualify planned behavior in the sentence where it appears.
- **Accessibility** — Keep focus indicators visible, preserve heading order, and support keyboard navigation and zoom. Include text labels for state, units on charts, and a text equivalent for diagrams that carry essential information.

### Quickstart specimen

From the repository root, create a two-line sample and run the shipper's scan command.

```sh
printf '%s\n' 'service started' 'listener ready' > app.log
cargo run -p quarrel-shipper -- scan ./app.log
```

Expected program output:

```text
0: service started
16: listener ready
2 lines, end_offset 31
```

The prefix on each log line is the byte offset where that line begins. The summary reports the number of complete lines and the offset after the final newline. Use `quarrel-shipper scan ./app.log` in condensed artwork where the binary is assumed to be on the command path.

## Handoff checks

- The wordmark reads **Quarrel** once, the arrow is visibly feathered, and the ground line ends at the final **l**.
- Light, dark, and monochrome assets use the same geometry. Check the mark at actual header and favicon sizes.
- Website and documentation share color roles, typography, and state labels. Verify links, focus states, code blocks, and narrow layouts in both themes.
- Validate example commands against the CLI and confirm feature claims against `Documentation/STATUS.md` and `Documentation/ROADMAP.md`. Product lineage comes from ADR-0002 for the toolkit, ADR-0004 for the proposed measurement model, and ADR-0005 for event and output direction.
