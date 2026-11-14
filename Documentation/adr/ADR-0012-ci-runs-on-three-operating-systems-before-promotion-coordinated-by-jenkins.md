# ADR-0012 — CI runs on Linux, Windows and macOS before promotion, coordinated by Jenkins

- **Status:** **Accepted 2026-11-14.** SB's ruling (shipping SOW OQ2). Not built yet (BL-0025).
- **Date:** 2026-11-14
- **Deciders:** SB
- **Scope:** Repo-level. Where quarrel's CI runs, what it checks, when, and how a rollup uses it.
- **Related:** ADR-0001 (gitolite is the system of record; GitHub receives only `master`); ADR-0003
  §1 and ADR-0006 (three platforms, no admin rights); ADR-0010 (the README check); the shipping SOW
  (Sc9, OQ5).

## Context

The shipping SOW's Sc9 needs proof on macOS, Linux and Windows. gitolite is the system of record and
GitHub sees only `master` after promotion (ADR-0001), so CI on GitHub could only confirm after the
fact. SB has a spare CentOS VM, will request a Windows VM, and uses a laptop as a desktop (docked,
normally on). macOS may only run on Apple hardware, so the macOS leg runs on that laptop.

## Decision

1. **Topology, all before promotion:**
   - **Coordinator: Jenkins on the CentOS VM.** It also runs the **Linux leg** in containers: build,
     `cargo test`, `cargo deny`, `cargo audit`, `scripts/check-readme.sh`, and a Windows
     cross-compile.
   - **Windows leg: a Windows VM** driven by Jenkins over SSH (Windows' built-in OpenSSH Server):
     build and `cargo test`.
   - **macOS leg: SB's laptop**, driven by Jenkins over SSH: build and `cargo test` for
     `aarch64-apple-darwin`, and for `x86_64-apple-darwin` under Rosetta 2.
2. **Trigger.** A push of any quarrel branch to gitolite triggers a pipeline run; the pipeline is a
   `Jenkinsfile` in the repo, so CI's definition is versioned and reviewed with the code. Wiring the
   trigger (a hook on the git server) and a read-only git identity for CI is a governed change on the
   git host, made through the governance repo.
3. **Least privilege, everywhere.** Each agent runs as a dedicated **non-admin** user (for example
   `quarrel-ci`); this is also how ADR-0003 §2's "no admin rights" is proven on every platform. CI
   has a read-only key to the git server and holds no publishing or signing secrets. Jenkins is on
   the internal network only, with authentication on, and a minimal, pinned set of plugins.
4. **macOS leg runs gently.** It runs at background priority (`taskpolicy -b`, limited parallelism)
   so it yields to SB's own work. The laptop is kept awake on mains power and reachable at a stable
   address.
5. **Windows leg hygiene.** Defender's real-time scanning excludes the build and test-temp folders
   (a scanner holding a file open makes rename and rotation tests fail for the wrong reason);
   updates reboot outside working hours; a snapshot is kept for rollback. The toolchain includes
   CMake, NASM and Go so the FIPS build (BL-0006) can run there later.
6. **The rollup gate.** A rollup promotes only a commit whose pipeline passed on **Linux and
   Windows**, and on **macOS** unless the macOS leg was *unavailable* (laptop away or asleep), in
   which case the rollup states the waiver explicitly. Never a silent skip; a macOS *failure* is never
   waived. Until CI is running (BL-0025), the macOS check is a local `cargo test` before each rollup.
7. **GitHub Actions is optional** and advisory: after a push to the public mirror, it may confirm
   the build for visitors (a badge) and check outside pull requests. It never gates anything.

## Consequences

- Every promoted commit is proven on all three platforms before `master` moves (bar a stated macOS
  waiver), which is what Sc9 and ADR-0006 require.
- If the macOS leg is unavailable often enough that waivers become routine, a dedicated Mac mini
  replaces the laptop as the agent; nothing else changes.
- Later, the result can be recorded on the commit (a git note) and the git server's hook can refuse
  to advance `master` without a passing result; that is a separate decision.
