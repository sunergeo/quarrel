# ADR-0006 — quarrel is production-grade observability tooling

- **Status:** **Accepted 2026-11-13.** SB's ruling on purpose. The requirements below are the bar;
  none of them is met yet.
- **Date:** 2026-11-13
- **Deciders:** SB
- **Scope:** Repo-level. Why quarrel exists, and what "production-grade" obliges every outcome to
  prove.
- **Amends:** ADR-0002 (Context, third paragraph: the learning-project framing).
- **Related:** ADR-0005 (vendor-neutral outputs); ADR-0007 (the shipper's OTLP contract).

## Context

ADR-0002 framed quarrel as "deliberately a public learning project". SB, 2026-11-13: quarrel needs
to be a production-grade suite of observability tools, fit to run unattended on real hosts in
demanding environments; learning Rust and low-level protocols is a by-product, and so is the
portfolio.

## Decision

1. **Purpose.** quarrel is production-grade observability tooling. Every outcome is judged by
   whether it can run unattended on production hosts. Learning and the public portfolio are welcome
   side effects; they never lower the bar or justify a shortcut.
2. **Independent and vendor-neutral.** quarrel serves any operator through open formats (ADR-0005).
   It names no particular consumer, backend or organisation, and carries no consumer-specific
   endpoints, protocols, contracts or defaults. A consumer with other needs adapts on its own side
   (ADR-0007 §1).
3. **"Production-grade" means these requirements**, each proven by an outcome's runnable DoD, not
   asserted:
   - **No silent loss.** At-least-once delivery; an offset is never saved past an acknowledged
     batch; anything that cannot be delivered (truncation, a file rotated away unread, a full
     buffer, undecodable bytes) is reported as a gap.
   - **Crash and outage safety.** A `kill -9` at any point, a restart, and a destination down for
     at least an hour all end with nothing lost and nothing reported healthy that is not.
   - **Rotation safety.** Rename, copy-truncate and compress-on-rotate are handled; a file is
     identified by its content (a fingerprint of its first bytes), not its inode.
   - **Bounded resources.** A stated, tested budget for memory, disk buffer and CPU per host.
   - **Honest health.** The tool reports itself healthy only when it is delivering, no tracked file
     is stale, and its buffer is not growing.
   - **Portable.** macOS, Windows and Linux, each tested in CI (for the shipper: SB 2026-11-13,
     as for the network tool in ADR-0003).
   - **Deployable and least-privilege.** A static binary; a container image and a hardened service
     unit; no root beyond what reading the files needs; read-only access to what it reads; config
     with the same keys in environment variables and a file.
   - **Secure transport.** TLS to the destination by default. A FIPS-validated TLS build is
     required for regulated environments; SB 2026-11-13: plain TLS first, FIPS tracked as a gap
     (BL-0006).
   - **Supply chain.** Reproducible builds from a signed tag; an SBOM; `cargo deny` and
     `cargo audit` in CI; OSI-licensed dependencies only. The source builds offline from vendored
     dependencies, so an operator can build it inside an isolated network.
   - **Time.** All timestamps are UTC with an explicit offset (`Z`) (ADR-0005).
4. **Open: where the network tool runs in a given deployment** (BL-0004). Some operators want
   measurements from outside their app hosts, and some restrict which outbound connections a host
   agent may open; quarrel-ping must run standalone wherever it is placed (ADR-0008 §3).

## Consequences

- Outcome SOWs carry these requirements into their DoD. The first is the shipper's
  `ensure-every-complete-log-line-reaches-an-otlp-collector-at-least-once`.
- No deployment should treat the shipper as production-ready until rotation, buffer, health and
  transport requirements are met as well.
- README and website claims stay at "in development" until the DoD scenarios pass (brand spec,
  feature claims).
