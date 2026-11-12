# quarrel

A small toolkit of host-side tools in Rust, one Cargo workspace (ADR-0002):

| Crate | What |
|---|---|
| `crates/quarrel-shipper` | The per-host log shipper: tails log files and ships the raw lines to an ingest endpoint. A static binary in a `scratch` image. (Formerly `argus`.) |
| `quarrel-core` | Planned: the shared event model, buffer, outputs and state. |
| `quarrel-probe` | Planned: an active network probe (latency, loss, MTR-style paths). |

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
cargo run -p quarrel-shipper --example factorial   # the day-2 warm-up
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
| `crates/quarrel-shipper/src/lessons.rs` | Warm-up exercises, kept as tested code. |
| `crates/quarrel-shipper/tests/` | Integration tests. Each file is its own crate using the public API. |
| `crates/quarrel-shipper/examples/` | Runnable examples (`cargo run -p quarrel-shipper --example <name>`). |
| `Dockerfile` | Static musl build → `scratch`. Tests run inside the build. |
| `docker-compose.yml` | Local dev only. |
| `Documentation/` | The governed funnel: `STATUS.md`, `ROADMAP.md`, `BACKLOG.md`, `adr/`. |

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
