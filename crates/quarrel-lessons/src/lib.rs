//! quarrel-lessons: exercises kept as real, tested code, one module per main idea.
//!
//! Nothing in quarrel calls this crate. The shipper and the probe use proven
//! libraries for anything a lesson reimplements; a lesson is where the idea
//! gets understood, beside the product and never inside it (ADR-0006 §1).
//!
//! Lessons are grouped by the utility they shape; module names are flat
//! (`quarrel_lessons::<idea>`), because an idea can shape more than one.
//!
//! | Utility | Module | Main idea | Status |
//! |---|---|---|---|
//! | Foundations | [`checked_arithmetic`] | Overflow is an error, not a surprise: checked operations, `Option` and `?` | done |
//! | quarrel-shipper | `compression` | Huffman coding, then an inflate/gzip decoder (BL-0008) | planned |
//! | quarrel-ping | `clocks` | What "now" costs and means on each OS (BL-0009) | planned |
//! | quarrel-ping | `latency_stats` | Summarising latency without lying (BL-0010) | planned |
//! | quarrel-ping | `coordinated_omission` | The classic latency-measurement trap (BL-0011) | planned |
//! | quarrel-ping | `loss_confidence` | How many probes a loss rate needs (BL-0012) | planned |
//! | quarrel-ping | `path_simulation` | Traceroute without sockets (BL-0013) | planned |
//! | quarrel-ping | `clock_sync` | One-way delay and why it is hard (BL-0014) | planned |
//! | quarrel-ping | `latency_anatomy` | Where the milliseconds come from (BL-0015) | planned |
//!
//! Each module's integration tests live in `tests/<module>.rs`; runnable
//! examples in `examples/` (`cargo run -p quarrel-lessons --example <name>`).

pub mod checked_arithmetic;
