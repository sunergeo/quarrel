<h1 align="center">
  <img src="Documentation/Brand/quarrel-wordmark-tagline.png" alt="Quarrel: Read the host. Measure the path." width="426">
</h1>

Quarrel is an open-source Rust toolkit for host-side observability: one Cargo workspace
(ADR-0002) that reads what the host's software reports, and will measure what the network did.

| Crate | What |
|---|---|
| `crates/quarrel-shipper` | In development. The per-host log shipper: tails log files and ships the raw lines to an ingest endpoint. A static binary in a `scratch` image. |
| `quarrel-core` | Planned: the shared event model, buffer, outputs and state. |
| `quarrel-ping` | Planned: PingPlotter-style network observability for a defined system. Continuously traces the paths between its endpoints: segments and who owns them, routing and route changes, per-hop latency and loss, and where bottlenecks are. |

This file is how to work on it. Run every command from the repository root.

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
| `Documentation/` | The governed funnel: `STATUS.md`, `ROADMAP.md`, `BACKLOG.md`, `adr/`. |
| `Documentation/Brand/` | The brand: [spec](Documentation/Brand/quarrel-brand-spec.md) (logo, colors, type, voice) and the approved board. |

## Not wired yet (roadmap M8)

Deployment packaging and CI. Until then the shipper is built and run by hand.

## License

Licensed under either of

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE))
- MIT license ([LICENSE-MIT](LICENSE-MIT))

at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted for inclusion in the
work by you, as defined in the Apache-2.0 license, shall be dual licensed as above, without any
additional terms or conditions.
