# quarrel — Roadmap

Forward-looking intent, grouped **Now · Next · Later** (`governance-core` §1). What we intend to do
and roughly in what order — **not** status, not dates. [`STATUS.md`](./STATUS.md) is the source of
truth; if the two disagree, `STATUS.md` wins. Every line traces to a SOW or a `BL-NNNN`; shipped
work leaves this file.

Milestones (M0–M8) are the shipper's milestone roadmap (it was `argus` until 2026-11-12), carried over from its previous repository. Shipped before
onboarding: M0 scaffold, M1 `scan`/`tail`, M2 persisted offsets.

## Now

- **[Ship to an OTLP collector, at least once](./Outcomes/ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once/SOW-ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once.md)**
  (SOW, Planned): ack-before-advance over OTLP/HTTP (ADR-0007), proven through `kill -9`, restarts
  and an hour-long outage on macOS, Linux and Windows. SB's first priority (2026-11-13). Its open
  questions (test collector, CI, resource budget, I/O model) come first.

- **Demo consumer, receiver and test mode first** (`BL-0019`, ADR-0009): the shipping SOW's test
  collector (D6). The React dashboard follows: shipper views now, quarrel-ping views after P2/P3.

- **M3 — discovery.** Step 1 landed (`fingerprint`: a file's identity by the sha256 of its first
  bytes, `d84c729`). Next: key offsets by fingerprint, survive rename/rotation, and stop exiting on
  a missing file (`BL-0002`). Needs a SOW before more code.

## Next

- **M4 — truncation.** A truncated file currently goes silent.

- **Health** (shipping SOW NG4): health as OTLP metrics, honest per ADR-0006 §3.

- **Document the OTLP output contract** for consumers building a receiver or adapter (`BL-0007`).

- **Stock-stack recipe** (`BL-0020`): quarrel feeding an OpenTelemetry Collector and Grafana.

- **FIPS-validated TLS** (`BL-0006`): for regulated deployments that require it.

- **Decide the probe's I/O model** (`BL-0003`), before P2.

## Later

quarrel-ping track (`BL-0004`; ADR-0002 to ADR-0005, ADR-0008; each step needs a SOW before code). Its purpose:
observability into what network traffic does within a defined system: segments, routing, latency,
bottlenecks (ADR-0008):

- **Workspace split, the rest.** Add `quarrel-core` and `quarrel-ping` to the workspace (ADR-0002, ADR-0008).
  The workspace and `quarrel-shipper` exist since 2026-11-12 (BL-0005).
- **P1 — ping one target.** ICMP echo, checksum, identifier/sequence numbers, datagram vs raw
  sockets, send/receive timing. macOS, Windows and Linux backends in CI (ADR-0003).
- **P2 — many targets, one socket, over time.** Continuous per-hop history (ADR-0008 §3). Reply matching, timeouts, send pacing. Accuracy compared with
  system `ping`, with the method written down (ADR-0004).
- **P3 — MTR-style path, with owners.** TTL-limited probes to the destination, quoted-header matching, reply
  rate-limit detection, stable flow identifiers (ADR-0004).
  Each hop labelled with the network that owns it, offline by default (ADR-0008 §5; datasets and
  licences `BL-0016`), and the segment where latency or loss begins named in words.
- **P4 — IPv6.** ICMPv6, extension headers, Packet Too Big, path-MTU discovery.
- **P5 — TCP and UDP probes.** Latency to hosts that block ICMP.
- **P6 — layer 2 (optional).** ARP/NDP via BPF, `AF_PACKET` or Npcap; needs privileges
  (ADR-0003).

- **TUI mode** (`BL-0017`, planned): run quarrel-ping standalone and watch a path live, no collector.
- **Native Windows/macOS clients** (`BL-0018`, possible enhancement, not committed).

Shipper track:

- **M8 — packaging and CI.** First deployment; the release model moves `trunk-only` → `rolling-pair`
  then (§11 governed operation).

Lessons (optional, never on the shipping path; `crates/quarrel-lessons`), by the utility they shape:

- **quarrel-shipper**
  - `compression`: Huffman coding and an inflate decoder (`BL-0008`), before M3's gzip rotation.
- **quarrel-ping**
  - `clocks`: what "now" costs and means on each OS (`BL-0009`), before P1.
  - `latency_stats`: summarising latency without lying (`BL-0010`), before P2.
  - `coordinated_omission`: the classic latency-measurement trap (`BL-0011`), before P2.
  - `loss_confidence`: how many probes a loss rate needs (`BL-0012`), before P2.
  - `path_simulation`: traceroute without sockets (`BL-0013`), before P3.
  - `change_points`: finding where a step change begins, CUSUM (`BL-0021`), before P3.
  - `clock_sync`: one-way delay and why it is hard (`BL-0014`), any time.
  - `latency_anatomy`: where the milliseconds come from (`BL-0015`), any time.
- **Foundations** (shipped): `checked_arithmetic` (the day-2 warm-up).
