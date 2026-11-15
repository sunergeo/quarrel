---
id: BL-0026
title: quarrel-shipper cannot yet install as a Windows service or ship systemd/launchd units (M8 service integration, ADR-0013)
type: Process-idea
status: Triaged
horizon: someday
big_idea: BI-02
reporter: SB (via Cowork agent)
opened: 2026-11-14
updated: 2026-11-14
affected: ADR-0013; crates/quarrel-shipper (service mode); packaging (M8)
disposition: null
---

# BL-0026 — Service integration (M8)

## Summary

ADR-0013: one foreground binary; the platform supervises it. The shipping SOW builds the seams (stop
token, single-instance lock, default paths, exit codes, readiness, log-sink setting). This item adds
what M8 packaging needs on top.

## Scope

1. **Windows service:** Service Control Manager integration (`windows-service` crate): status
   reporting, stop/shutdown/pre-shutdown handling with wait hints, mapped onto the stop token;
   `service install | uninstall | start | stop`; a low-privilege account (`LocalService` or a virtual
   service account); recovery actions that do not restart on configuration errors.
2. **Windows Event Log** log sink.
3. **`service print-unit systemd`:** a hardened unit (`Type=notify` or `simple`, `Restart=on-failure`,
   `RestartPreventExitStatus=` for configuration errors, `NoNewPrivileges`, `ProtectSystem=strict`,
   `ReadOnlyPaths=` for logs, `StateDirectory=quarrel`, `MemoryMax=64M`).
4. **`service print-unit launchd`:** LaunchDaemon and LaunchAgent plists (`KeepAlive`, log paths).
5. **Docs:** each mode, with the account and file-permission setup it needs (for example, group
   membership to read system logs).
6. **Tests:** install, start, stop, uninstall on each OS in CI; a stop arriving mid-batch ends
   cleanly in every mode.

## Log

- 2026-11-14 — Captured with ADR-0013.
