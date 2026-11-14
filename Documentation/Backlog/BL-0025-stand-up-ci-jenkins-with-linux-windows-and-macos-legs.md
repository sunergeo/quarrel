---
id: BL-0025
title: Stand up CI per ADR-0012 — Jenkins on the CentOS VM, Windows VM and laptop agents, triggered by gitolite
type: Process-idea
status: Triaged
horizon: now
big_idea: BI-02
reporter: SB (via Cowork agent)
opened: 2026-11-14
updated: 2026-11-14
affected: ADR-0012; Jenkinsfile (planned); git server (trigger hook, read-only CI identity)
disposition: null
---

# BL-0025 — Stand up CI (ADR-0012)

## Summary

ADR-0012 decides the topology; this item builds it. Needed before the shipping SOW's Sc9 can pass.

## Steps

1. **CentOS VM:** Jenkins (LTS, internal only, auth on, minimal pinned plugins); Docker with the
   nftables firewall backend (CentOS 10); a Rust build image for the Linux leg.
2. **Windows VM** (SB requests it): Windows 11 Pro or Server 2022/2025; 4 vCPU, 8 GB, 100 GB;
   virtio drivers if on KVM; OpenSSH Server; a non-admin `quarrel-ci` user; `rustup`
   (x86_64-pc-windows-msvc), Visual Studio 2022 Build Tools (C++ workload; confirm licence terms),
   CMake, NASM, Go, Git; Defender exclusions for build and test-temp folders; update reboots out of
   hours; a snapshot.
3. **Laptop (macOS leg):** Remote Login on; a non-admin `quarrel-ci` user with its own toolchain and
   both Apple targets; `sudo pmset -c sleep 0`, `tcpkeepalive 1`; a DHCP reservation or stable
   `.local` name; jobs wrapped in `taskpolicy -b` with limited `-j`.
4. **Jenkins wiring:** SSH credentials for the two agents; a read-only gitolite identity for CI.
5. **Git server:** a hook that notifies Jenkins on any push to `quarrel`, and the CI identity's read
   access. A governed change in the governance repo (gitolite-admin).
6. **`Jenkinsfile`** in the repo: parallel Linux / Windows / macOS stages; macOS marked
   *unavailable* (not failed) when unreachable.
7. **Rollup:** once green end to end, quarrel's rollup checks the pipeline result for the commit
   being promoted (ADR-0012 §6).

## Log

- 2026-11-14 — Captured with ADR-0012. SB will request the Windows VM.
