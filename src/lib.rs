//! Argus: the per-host log shipper.
//!
//! One Argus runs on each host. It tails log files and ships the raw lines to
//! an ingest endpoint. Parsing happens downstream, not here; Argus is a dumb,
//! reliable shipper.
//!
//! The one invariant: never save a file offset past what the destination has
//! acknowledged. Sending a line twice is harmless (the destination dedupes);
//! skipping one is the only real failure.
//!
//! Built step by step along a learning roadmap. Today it only knows its own name; tailing arrives in M1.

pub mod lessons;
pub mod scan;
pub mod state;

/// The crate name, read from `Cargo.toml` at compile time.
pub const NAME: &str = env!("CARGO_PKG_NAME");

/// The crate version, read from `Cargo.toml` at compile time.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// What `argus --version` prints, e.g. `argus 0.1.0`.
pub fn version_line() -> String {
    format!("{NAME} {VERSION}")
}

/// The environment Argus is running in, from `ARGUS_ENV` (defaults to `dev`).
pub fn environment() -> String {
    std::env::var("ARGUS_ENV").unwrap_or_else(|_| String::from("dev"))
}

/// Run the agent. Today: announce itself and exit. M1 replaces the body with
/// the tail loop.
pub fn run() -> Result<(), Box<dyn std::error::Error>> {
    println!("{} starting (env: {})", version_line(), environment());
    println!("nothing to ship yet: tailing arrives in roadmap M1");
    Ok(())
}
