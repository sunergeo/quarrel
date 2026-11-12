# syntax=docker/dockerfile:1
#
# quarrel-shipper: ONE image for dev, staging and prod. What differs between environments
# is runtime configuration (QUARREL_ENV today, a config file from M8), never the
# build.
#
# The build context is the repository root:
#
#   docker build -t quarrel-shipper:dev .
#
# .dockerignore keeps local build output out of the context.
#
# Build a static musl binary, then copy it alone into an empty `scratch`
# image.

# Rust on Alpine targets musl, so the binary is statically linked: it needs no
# libc at runtime, which is what lets the final stage be `scratch`.
ARG RUST_VERSION=1
FROM rust:${RUST_VERSION}-alpine AS build

RUN apk add --no-cache musl-dev

WORKDIR /src
COPY . ./

# Tests run inside the build, so an image only exists if the tests pass. This is
# also how CI will test the workspace (roadmap M8).
# `--locked` refuses to build if Cargo.lock is missing or out of date.
# The cache mounts keep downloaded crates and compiled output between builds;
# because target/ is a cache mount, the binary is copied out in the same step.
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/src/target \
    cargo test --workspace --locked \
    && cargo build --release --locked -p quarrel-shipper \
    && cp target/release/quarrel-shipper /quarrel-shipper

FROM scratch
COPY --from=build /quarrel-shipper /quarrel-shipper
ENTRYPOINT ["/quarrel-shipper"]
