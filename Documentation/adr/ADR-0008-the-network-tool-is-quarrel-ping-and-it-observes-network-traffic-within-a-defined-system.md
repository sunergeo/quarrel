# ADR-0008 — The network tool is quarrel-ping: observability into what network traffic actually does within a defined system

- **Status:** **Accepted 2026-11-13.** SB's ruling on name and purpose. Nothing of the tool is built
  yet; §3 lists what the purpose obliges it to do.
- **Date:** 2026-11-13
- **Deciders:** SB
- **Scope:** Repo-level. The network tool's name, what it is for, and the capabilities that purpose
  requires.
- **Amends:** ADR-0002 §1 and §4 (the crate was `quarrel-probe`); the titles of ADR-0003 and
  ADR-0004, whose decisions now apply to `quarrel-ping` unchanged.
- **Related:** ADR-0004 (measurement model); ADR-0005 (outputs); ADR-0006 §4 (where it runs in a given
  deployment, open); BL-0004.

## Context

ADR-0002 named the network tool `quarrel-probe` and described it generically: "sends its own probes
and reports what the network did". SB, 2026-11-13: the tool is modelled on PingPlotter. SB then set its scope wider than any single use: the overall purpose is **observability
into what is actually happening with network traffic within a defined system**: its segments, its
routing, its latency and its bottlenecks. Isolating the bottleneck when users report slowness is one
use case, the one PingPlotter is best known for, not the definition.

## Decision

1. **Name:** `quarrel-ping` (crate and binary). "Probe" stays a common noun: the tool sends probes.
   (`quarrel-ping`'s availability on crates.io is to be confirmed; publishing is still a separate
   decision, ADR-0002 §4.)
2. **Purpose: observability into what network traffic actually does within a defined system.**
   - **The defined system** is what the operator declares: the endpoints that matter (sites, hosts,
     services, user locations) and the vantage points quarrel-ping measures from. quarrel-ping
     measures the paths between them, continuously, and reports what it finds as telemetry.
   - **What it makes observable:**
     - **Segments:** the hops that make up each path, who owns them (§5), and which segments
       several paths share.
     - **Routing:** which route traffic actually takes, when it changes, and whether it differs by
       direction or flow.
     - **Latency, loss and jitter:** per hop and per segment, over time, with baselines to compare
       against.
     - **Bottlenecks:** where along a path latency or loss begins, and whether it is real or an
       artefact of how routers answer probes.
   - **Use cases it serves** (none of them is the definition): isolating the bottleneck when users
     report slowness; establishing and watching baselines; detecting route changes and their
     effect; seeing a shared segment degrade across many paths at once; giving an ISP or carrier
     evidence; checking a network change did what it was meant to.
3. **What the purpose requires** (each becomes SOW scope and DoD, not a promise here):
   - **A declared system, not one target.** Configuration names the endpoints and vantage points;
     quarrel-ping measures every declared path, and its output says which path each measurement
     belongs to.
   - **Per-hop, continuously, over time.** It traces each path repeatedly at a configured interval
     and keeps per-hop latency and loss **as a time series**, so any past moment (a user's
     complaint, a change window) can be examined afterwards. A one-shot traceroute does not answer
     the question.
   - **Shared segments.** Hops and segments that appear on several paths are identified as the same
     segment, so a problem in one shared segment shows up as one cause, not many symptoms.
   - **Real loss versus reply rate limiting.** Loss that begins at a hop and **persists to the
     destination** points at that segment; loss at one hop that does not carry forward is that
     router de-prioritising its replies (ADR-0004 §6). The tool says which, in words.
   - **Segment attribution.** The output names the first hop where latency or loss steps up and
     stays up, with the evidence (before/after figures and confidence), rather than leaving the
     reader to eyeball a table.
   - **Route changes are events.** A change of hops is reported when it happens (ADR-0005 §3), since
     it often explains a step in latency.
   - **Run from the right end.** The useful vantage point is often the affected user's side, or both
     ends. Where it runs in a given deployment stays open (ADR-0006 §4, BL-0004); the tool must support running
     standalone on a user's machine as well as on a server.
   - **A shareable result.** A time window's per-hop summary can be exported (NDJSON per ADR-0005;
     a human-readable report) so it can be attached to a support ticket or sent to an ISP.
   - **Who owns each segment.** Each hop is labelled with the network it belongs to, and consecutive
     hops in the same network are grouped into one segment ("your network", "your ISP", a transit
     carrier, an exchange point, the destination's network), so the answer reads "the loss starts
     inside carrier X", not just "at hop 7". See §5 for how.
4. **Two ways to use it, one source of numbers** (SB, 2026-11-13).
   - **For observability, it only emits OTLP.** Per-hop metrics and events, labelled with target,
     hop, address, network owner and segment (ADR-0005), go to whatever collector the operator
     configures. Dashboards, graphs and alerts are the consumer's to build; nothing about them lives
     in quarrel.
   - **Interactive: a standalone terminal UI (TUI) mode, planned for the future.** A user (or a
     support engineer on the user's machine) starts it and watches per-hop latency, loss, the time
     graph and segment attribution update live, without any collector. It reads the same
     measurement engine as the OTLP output, so the two can never disagree. → BL-0017.
   - **Possible enhancement: native Windows and macOS clients.** A desktop app for non-technical
     users, closer to PingPlotter's own experience, built on the same engine (as a library) and
     shipped separately. Not committed; recorded so the engine's API is designed with a GUI
     consumer in mind. → BL-0018.
5. **Network ownership: offline by default, online lookups only by explicit opt-in.**
   - **How a hop is attributed.** In order of authority: special-purpose ranges labelled locally
     (RFC 1918 private → "local network"; `100.64.0.0/10` → "carrier NAT, inside your ISP";
     loopback/link-local); exchange-point peering ranges → "exchange point <name>"; otherwise the
     hop address's **origin AS** (longest matching announced prefix) and that AS's organisation
     name. Reverse-DNS names and registry (RDAP) records are supporting evidence, shown but never
     overriding the AS.
   - **Where the data comes from, by default: local files.** A prefix-to-origin-AS table, an
     AS-to-organisation table and exchange-point prefixes, loaded from configured paths and
     replaceable without a rebuild. quarrel ships a tool, or documented steps, to build them from
     public routing and registry dumps; it does not hard-wire one vendor's dataset. This works
     offline, inside an enclave, and leaks no hop addresses to third parties.
   - **Online sources are opt-in, one by one:** reverse DNS (through the host's configured
     resolver), an IP-to-AS DNS service, registry RDAP. Each is off unless configured, because each
     sends hop addresses somewhere, and many environments allow only documented outbound flows.
   - **Every attribution carries a confidence and its source.** Known traps are stated, not hidden:
     a border router often answers from an address in its *neighbour's* space, so a change of owner
     between two hops is reported as "boundary between X and Y"; MPLS can hide hops; the reply's
     return path may differ. A stale dataset is reported (its build date travels with the label).
   - **Licences.** Every dataset quarrel documents or builds must have terms compatible with
     redistribution in an open-source project and with OSI-only licence policies; datasets under
     restrictive end-user licences are not bundled or recommended. → BL-0016.

## Consequences

- Every live reference to `quarrel-probe` becomes `quarrel-ping`. ADR-0003 and ADR-0004 keep their
  file names (ids are immutable) and carry an amendment note; ADR-0002's naming clauses are struck
  through and marked inline.
- The P1–P6 roadmap stands, but P2/P3 gain "over time, with history", a declared set of paths, and
  segment and shared-segment output; they belong in the first quarrel-ping SOW's DoD.
- Network ownership becomes P3 scope (it needs hops); its dataset choice and licence check are
  BL-0016. The engine is a library with the CLI/OTLP exporter, the future TUI (BL-0017) and any
  native client (BL-0018) as consumers of it.
- The probe lessons (BL-0009 to BL-0015) now shape quarrel-ping; `loss_confidence` and
  `path_simulation` directly support the "real loss versus rate limiting" and attribution
  requirements.
