# argus

The per-host log shipper: tails log files and ships the raw lines to an
ingest endpoint. Rust, a static binary in a `scratch` image.

This file is how to work on it.

## First time

```bash
cargo build        # creates Cargo.lock; commit it
cargo test
```

`Cargo.lock` must exist before the Docker build, which runs with `--locked`.

## The daily loop

```bash
bacon clippy                     # leave running; re-checks on every save
bacon test                       # or: cargo test
cargo run                        # run the agent
cargo run -- --version
cargo run --example factorial    # the day-2 warm-up
```

## Docker (the same image for dev, staging and prod)

```bash
docker compose up --build              # build (tests run inside) and run
docker compose run --rm argus --version
```

Or without compose, exactly as CI will build it:

```bash
docker build -t argus:dev .
```

## Layout

| Path | What |
|---|---|
| `src/lib.rs` | The library. All real logic goes here, so tests can reach it. |
| `src/main.rs` | The binary. A thin shell over the library. |
| `src/lessons.rs` | Warm-up exercises, kept as tested code. |
| `tests/` | Integration tests. Each file is its own crate using the public API. |
| `examples/` | Runnable examples (`cargo run --example <name>`). |
| `Dockerfile` | Static musl build → `scratch`. Tests run inside the build. |
| `docker-compose.yml` | Local dev only. |

## Not wired yet (roadmap M8)

Deployment packaging and CI. Until then Argus is built and run by hand.
