<h1 align="center">
  <img src="Documentation/Brand/quarrel-wordmark-tagline.png" alt="Quarrel: Read the host. Measure the path." width="426">
</h1>

Quarrel is an open-source Rust toolkit for host-side observability: one Cargo workspace
([ADR-0002](Documentation/adr/ADR-0002-quarrel-is-one-toolkit-a-shared-core-with-a-shipper-and-a-probe.md))
that reads what the host's software reports, and will measure what the network did.

**Production-grade by design, not yet production-ready.** Quarrel is built to run unattended on
real hosts: no silent loss, crash and outage safety, bounded resources, honest health reporting,
least privilege, reproducible builds
([ADR-0006](Documentation/adr/ADR-0006-quarrel-is-production-grade-observability-tooling.md)).
Each of those is proven by a runnable test before it is claimed; until then every tool here is
**in development** or **planned**.

| Crate | What |
|---|---|
| `crates/quarrel-shipper` | **In development.** The per-host log shipper. Today it scans and tails log files, reports each complete line with its byte offset, and saves offsets so it resumes after a restart. Next: ship lines over OTLP at least once, through crashes, restarts and outages. A static binary in a `scratch` image. |
| `quarrel-core` | **Planned.** The shared event model, buffer, outputs and state. |
| `quarrel-ping` | **Planned.** PingPlotter-style network observability for a defined system. Continuously traces the paths between its endpoints: segments and who owns them, routing and route changes, per-hop latency and loss, and where bottlenecks are. A standalone terminal UI for watching a path live is planned too. |
| `quarrel-demo` | **Planned.** A demo consumer in one Docker image. An OTLP endpoint both tools can send to, and a web dashboard showing how to use them. For demos, development and testing, not production. |
| `crates/quarrel-lessons` | Tested exercises beside the product, never in it: ideas the tools depend on (latency statistics, loss confidence, Huffman coding, change-point detection, …) built by hand and checked against proven libraries. Each names the mathematics it exercises. |

**How it fits your stack.** Quarrel's tools emit **OTLP** (OpenTelemetry) only, so they work with
any OpenTelemetry-compatible collector or backend. Quarrel ships no dashboards of its own:
build them in whatever you already use, or start from `quarrel-demo`
([ADR-0007](Documentation/adr/ADR-0007-quarrel-shipper-delivers-over-otlp-http-and-advances-only-on-acknowledgement.md),
[ADR-0009](Documentation/adr/ADR-0009-quarrel-ships-a-demo-consumer-for-demonstration-development-and-testing.md)).

**Platforms.** macOS, Linux and Windows, each tested; no root or administrator rights for core
features ([ADR-0003](Documentation/adr/ADR-0003-quarrel-ping-is-portable-by-construction.md)).

**Where it's going.** The [Big Ideas](Documentation/BIG-IDEAS.md) (never lose a line; see the network
as it is; explain where the time goes), the [roadmap](Documentation/ROADMAP.md) and the
[current status](Documentation/STATUS.md).

The rest of this file is how to work on it. Run every command from the repository root.

## First time

```bash
cargo build        # writes Cargo.lock; commit it
cargo test         # every crate in the workspace
```

`Cargo.lock` must exist before the Docker build, which runs with `--locked`.

## The daily loop

```bash
bacon clippy                                       # leave running; re-checks on every save
bacon test                                         # or: cargo test
cargo run -p quarrel-shipper                       # run the shipper
cargo run -p quarrel-shipper -- --version
cargo run -p quarrel-shipper -- tail <file> <state>
cargo run -p quarrel-lessons --example factorial   # the day-2 warm-up
```

`QUARREL_ENV` names the environment (`dev` by default).

## Docker (the same image for dev, staging and prod)

```bash
docker compose up --build                        # build (tests run inside) and run
docker compose run --rm quarrel-shipper --version
```

Or without compose, exactly as CI will build it:

```bash
docker build -t quarrel-shipper:dev .
```

## Layout

| Path | What |
|---|---|
| `Cargo.toml` | The workspace: members, shared package fields, the release profile. |
| `crates/quarrel-shipper/src/lib.rs` | The shipper library. All real logic goes here, so tests can reach it. |
| `crates/quarrel-shipper/src/main.rs` | The shipper binary. A thin shell over the library. |
| `crates/quarrel-shipper/tests/` | Integration tests. Each file is its own crate using the public API. |
| `crates/quarrel-lessons/` | Tested exercises, one module per main idea (`src/lib.rs` lists them); never shipped. Examples: `cargo run -p quarrel-lessons --example <name>`. |
| `Dockerfile` | Static musl build → `scratch`. Tests run inside the build. |
| `docker-compose.yml` | Local dev only. |
| `Documentation/` | The plans, versioned with the code: `BIG-IDEAS.md` and `BigIdeas/` (strategy), `STATUS.md`, `ROADMAP.md`, `Outcomes/` (one statement of work per outcome), `BACKLOG.md` and `Backlog/`, `adr/` (decisions). |
| `Documentation/Brand/` | The brand: [spec](Documentation/Brand/quarrel-brand-spec.md) (logo, colors, type, voice) and the approved board. |

## Not wired yet (roadmap M8)

Deployment packaging and CI. Until then the shipper is built and run by hand.

## Contributing

Issues and pull requests are welcome on GitHub. The GitHub repository is a read-only mirror of the
primary repository, so pull requests are not merged there: an accepted change is applied in the
primary repository, keeping your authorship, and reaches GitHub with the next mirror push
([ADR-0001](Documentation/adr/ADR-0001-quarrel-is-published-as-a-public-github-mirror-of-gitolite.md)).

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE))
- MIT license ([LICENSE-MIT](LICENSE-MIT))

at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the
work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
