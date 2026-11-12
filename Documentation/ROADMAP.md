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

- **Decide the probe's I/O model** (`BL-0003`), before P2.

## Later

Probe track (`BL-0004`; ADR-0002 to ADR-0005; each step needs a SOW before code):

- **Workspace split.** `quarrel-core` + `quarrel-shipper` (today's `argus`, renamed) +
  `quarrel-probe` (ADR-0002).
- **P1 — ping one target.** ICMP echo, checksum, identifier/sequence numbers, datagram vs raw
  sockets, send/receive timing. macOS, Windows and Linux backends in CI (ADR-0003).
- **P2 — many targets, one socket.** Reply matching, timeouts, send pacing. Accuracy compared with
  system `ping`, with the method written down (ADR-0004).
- **P3 — MTR-style path.** TTL-limited probes to the destination, quoted-header matching, reply
  rate-limit detection, stable flow identifiers (ADR-0004).
- **P4 — IPv6.** ICMPv6, extension headers, Packet Too Big, path-MTU discovery.
- **P5 — TCP and UDP probes.** Latency to hosts that block ICMP.
- **P6 — layer 2 (optional).** ARP/NDP via BPF, `AF_PACKET` or Npcap; needs privileges
  (ADR-0003).

Shipper track:

- **M8 — packaging and CI.** First deployment; the release model moves `trunk-only` → `rolling-pair`
  then (§11 governed operation).
