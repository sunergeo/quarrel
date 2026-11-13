# ADR-0003 — quarrel-ping is portable by construction: macOS first, Windows and Linux supported

- **Status:** **Accepted 2026-11-12.** Nothing of the probe is built yet.
- **Date:** 2026-11-12
- **Amended:** 2026-11-13 by `ADR-0008`: the tool's name (title only; the decision is unchanged).
- **Deciders:** SB
- **Scope:** Repo-level. Which platforms the probe supports, how platform differences are contained,
  and where the probe's ideas may come from.
- **Related:** ADR-0002 (toolkit); ADR-0004 (measurement); `BL-0003` (the probe's I/O model, open).

## Context

The project is developed on macOS but must also run on Windows. Keeping one codebase clean across
both is part of what the project demonstrates. For a network probe the differences are fundamental,
not cosmetic:

| | macOS | Linux | Windows |
|---|---|---|---|
| ICMP without root/admin | datagram ICMP socket (`SOCK_DGRAM`/`IPPROTO_ICMP`); the caller builds the ICMP header and receives the IP header with each reply | datagram ICMP socket, subject to `net.ipv4.ping_group_range`; the kernel rewrites the echo identifier and strips the IP header | no unprivileged ICMP socket; raw sockets need admin. The unprivileged path is `IcmpSendEcho2Ex` (iphlpapi) |
| Receive timestamps | kernel timestamps (`SO_TIMESTAMP`), microsecond resolution | kernel timestamps (`SO_TIMESTAMP`/`SO_TIMESTAMPNS`) | the API reports whole milliseconds |
| Layer 2 (ARP/NDP) | `/dev/bpf` | `AF_PACKET` | needs a capture driver (Npcap) |

An earlier internal Electron tool prompted this project. It works, but it is tied to Windows,
reports milliseconds only and runs its probes on a shared thread pool. quarrel takes none of its
code.

## Decision

1. **Supported platforms:** macOS is the development and first-class platform. Windows is
   supported. Linux is supported and is built and tested in CI, because its socket semantics differ
   from macOS and so test whether the abstraction is honest.
2. **No root or admin required for the core features** (ping, path discovery, per-hop
   measurement) on any supported platform. A feature that needs privileges (raw-socket modes,
   layer 2) is optional, says so, and degrades cleanly without them.
3. **Packet code is pure.** Encoding and decoding of ICMPv4/ICMPv6, IPv4/IPv6 and UDP headers
   lives in an I/O-free module (a crate of its own when ADR-0002 §1 says it earns one). It is
   property-tested, fuzzed, and checked against captured packets (`.pcap` fixtures).
4. **Platform differences live behind one trait.** A `Prober`-style trait defines "send this probe,
   deliver what came back with its timing". Each platform backend is selected at compile time
   (`#[cfg]`):
   - **macOS and Linux:** datagram ICMP sockets (raw sockets optionally).
   - **Windows:** `IcmpSendEcho2Ex` (raw sockets optionally, with admin).

   Everything above the trait is written once and tested without a network.
5. **`unsafe` is confined to the backends.** Every `unsafe` block carries a `// SAFETY:` comment.
6. **Clean-room provenance.** The probe is built from public specifications: the ICMP, ICMPv6 and
   RTP RFCs (RFC 792, RFC 4443, RFC 3550), the traceroute literature (MTR, Paris traceroute) and the
   operating systems' socket documentation. The code cites those sources, not any prior
   implementation.

## Consequences

- **CI runs a three-platform matrix** (macOS, Windows, Linux) from the first probe milestone. A
  backend that only works on the developer's machine is not done.
- **Windows accuracy is bounded by its API:** whole milliseconds, unless the optional raw-socket
  backend is used. ADR-0004's precision claims are therefore stated per platform.
- **Layer-2 tools are a later, optional milestone** (P6), because they need a capture driver on
  Windows and privileges everywhere.
- **The I/O model is not decided here.** Async (Tokio) or a synchronous loop over non-blocking
  sockets is `BL-0003`. Both fit behind the trait in §4.
