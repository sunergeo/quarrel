# ADR-0004 — quarrel-probe measures paths the way MTR does, with timing it can defend

- **Status:** **Proposed 2026-11-12.** This is the recommended measurement model; SB has not yet
  ruled on it clause by clause. It becomes Accepted when P1–P3 confirm it in code.
- **Date:** 2026-11-12
- **Deciders:** SB
- **Scope:** Repo-level. What the probe's numbers mean: how probes are sent and matched, how time is
  taken, and how loss, latency and jitter are computed.
- **Related:** ADR-0003 (portability; precision differs by platform); ADR-0005 (how the numbers are
  emitted).

## Context

A latency, jitter and loss monitor is only as useful as the meaning of its numbers. Common
shortcuts each give a number that looks right and means something else:

- **Pinging each hop's IP address directly** measures that router's reply to pings sent *to it*,
  possibly over a different interface or return path. It does not measure the path to the
  destination.
- **Discovering the path once, with one probe per TTL,** collapses load-balanced (ECMP) paths to
  whichever router answered first.
- **Stamping a sample when it completes** (after a timeout, for a loss) skews the timeline by up to
  the timeout.
- **Millisecond-only timing** makes LAN jitter mostly rounding noise.
- **Treating a router that rate-limits its ICMP replies as lossy** blames a hop for its control
  plane, not its forwarding.

## Decision

1. **Per-hop measurement is MTR-style.** Each cycle sends probes to the *destination* with
   increasing TTL. The probe identifies each hop by the ICMP Time Exceeded reply, and matches each
   reply to its probe using the original header the router quotes back. Hop IPs are never pinged
   directly.
2. **Every probe is matched by identity, not by order.** A probe carries an identifier and a
   sequence number (and, for UDP/TCP probes, a flow tuple). Replies are matched by those values. One
   socket per address family serves every target.
3. **Time is taken at send and receive with a monotonic clock**, using kernel receive timestamps
   where the platform has them. A sample is stamped with its *send* time. Wall-clock time (UTC) is
   attached for reporting only, never used for durations.
4. **Precision is stated per platform, not assumed.** Microseconds where the backend provides them
   (macOS and Linux sockets); whole milliseconds through `IcmpSendEcho2Ex` on Windows (ADR-0003).
   Every sample records which backend took it.
5. **Statistics are defined, not improvised:**
   - **Loss** is a probe with no matching reply within its timeout. Late replies are counted
     separately, not as loss.
   - **Latency** is reported as min, mean, max and percentiles from a histogram, not a mean alone.
   - **Jitter** is the RFC 3550 interarrival estimator (the 1/16 smoothed mean deviation). The
     simple mean of consecutive differences may also be reported, under its own name.
   - **Rolled-up figures** are weighted by sample count. A mean of means is never reported as a
     mean.
6. **Router ICMP rate limiting is surfaced, not hidden.** Loss at an intermediate hop that does not
   persist to later hops is reported as likely reply rate limiting, distinct from forwarding loss.
7. **Load-balanced paths:** probes hold the flow identifier constant (Paris-traceroute style), so a
   flow follows one path. Discovering *all* paths across a load balancer is a later option, not the
   default.
8. **IPv6 is a first-class target** (ICMPv6, including Packet Too Big). Path-MTU discovery is a
   planned feature, not an afterthought.

## Consequences

- **The probe's numbers can be compared with system `ping` and `mtr`.** That comparison, with its
  method written down, is part of P2's Definition of Done.
- **Matching replies, timeouts and timestamps is the hard core of the probe**, and it is the
  learning P2 is built around. It cannot be delegated to a ping crate.
- **On Windows without admin, matching is done by the API, not by the probe.** The trait in
  ADR-0003 must allow a backend that matches replies itself.
