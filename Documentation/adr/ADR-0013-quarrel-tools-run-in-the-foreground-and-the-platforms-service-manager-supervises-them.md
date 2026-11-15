# ADR-0013 — quarrel's tools run in the foreground, and the platform's service manager supervises them

- **Status:** **Accepted 2026-11-14.** SB's ruling. The seams are built in the shipping SOW; service
  integration is M8 (BL-0026).
- **Date:** 2026-11-14
- **Deciders:** SB
- **Scope:** Repo-level. How quarrel's long-running tools behave as a console app, a background
  process, a Linux or macOS daemon, a Windows service or a container.
- **Related:** ADR-0006 (deployable, least privilege, same keys in env and file); ADR-0011
  (synchronous shipper); the shipping SOW and its architecture note (D18–D20).

## Context

SB wants the shipper usable as a terminal app, a background process, a daemon or a Windows service,
as each user decides. Modern supervisors (systemd, launchd, the Windows Service Control Manager,
Docker) all expect a program that runs in the foreground and responds to their stop requests; the
old Unix self-daemonising fork works against them.

## Decision

1. **One binary, always foreground.** `quarrel-shipper run` is the program every mode uses. quarrel
   never forks itself into the background; supervising is the platform's job:
   - **console:** run it in a terminal; Ctrl-C stops it cleanly;
   - **background process:** the same, with output redirected (`nohup`, a hidden window);
   - **Linux:** systemd (a hardened unit: `Restart=on-failure`, `NoNewPrivileges`, `MemoryMax=` from
     the shipper's budget); logs to stdout/stderr for the journal; optional readiness notification;
   - **macOS:** launchd (a system LaunchDaemon or a per-user LaunchAgent, `KeepAlive`);
   - **Windows:** a real Windows service (it speaks the Service Control Manager's protocol: status
     reports, stop and shutdown within the deadline), run under a low-privilege service account;
     installing needs admin once, running does not;
   - **containers:** foreground, handling `SIGTERM` as process 1.
2. **Every stop request is one stop token.** Ctrl-C, `SIGINT`, `SIGTERM`, a Windows service stop or
   shutdown, a console closing: all set the same token, which the run loop honours by ending cleanly
   within a deadline, never by breaking the tool's invariants.
3. **One instance per state folder**, enforced by a lock file.
4. **Absolute, per-platform default paths** for config, state and logs, all overridable; a service's
   working folder is never relied on.
5. **Exit codes tell supervisors what to do:** a configuration error must not cause a restart loop;
   a runtime failure may be restarted.
6. **Readiness means working:** a tool reports itself started only after its configuration validated
   and its lock is held.
7. **Log destination is a setting:** stderr by default (readable on a terminal, JSON on request), a
   file, or the Windows Event Log as a service. A tool's own log folder is never shipped.
8. **Command-line shape:** `run`, `check-config`, `service install | uninstall | start | stop`
   (Windows), `service print-unit systemd | launchd`; existing diagnostics (`scan`, `tail`) stay.
9. **The same rules apply to quarrel-ping** when it gains a long-running mode.

## Consequences

- The shipping SOW builds the seams (2–7) because its restart and kill scenarios need them; M8 adds
  the Windows service code, the unit files and plists, the Event Log sink and their docs without
  reworking the core (BL-0026).
- The README's commands and platform notes change when `run` and the service modes land (ADR-0010).
