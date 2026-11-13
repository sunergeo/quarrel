//! quarrel-lessons: exercises kept as real, tested code, one module per main idea.
//!
//! Nothing in quarrel calls this crate. The shipper and quarrel-ping use proven
//! libraries for anything a lesson reimplements; a lesson is where the idea
//! gets understood, beside the product and never inside it (ADR-0006 §1).
//!
//! Each lesson also names the mathematics it exercises, so the crate doubles as
//! a worked-exercise set for probability, statistics and discrete maths.
//!
//! Lessons are grouped by the utility they shape; module names are flat
//! (`quarrel_lessons::<idea>`), because an idea can shape more than one.
//!
//! | Utility | Module | Main idea | Math it exercises | Status |
//! |---|---|---|---|---|
//! | Foundations | [`checked_arithmetic`] | Overflow is an error, not a surprise: checked operations, `Option` and `?` | n! as a product (Π); bounds via logarithms (why 20! fits in 64 bits and 21! does not) | done |
//! | quarrel-shipper | `compression` | Huffman coding, then an inflate/gzip decoder (BL-0008) | prefix codes and trees; a greedy algorithm and its optimality proof; entropy H = −Σ p·log₂ p; the Kraft inequality Σ 2^(−ℓᵢ) ≤ 1 | planned |
//! | quarrel-ping | `clocks` | What "now" costs and means on each OS (BL-0009) | empirical distributions; resolution and measurement error | planned |
//! | quarrel-ping | `latency_stats` | Summarising latency without lying (BL-0010) | Σ, E[X], Var(X); Welford's recurrence; quantiles; log-scale buckets; exponential smoothing (RFC 3550 jitter) | planned |
//! | quarrel-ping | `coordinated_omission` | The classic latency-measurement trap (BL-0011) | sampling bias; conditional probability; Monte Carlo simulation | planned |
//! | quarrel-ping | `loss_confidence` | How many probes a loss rate needs (BL-0012) | Bernoulli and binomial distributions; confidence intervals (Wilson score); the Bayesian view (Beta posterior) | planned |
//! | quarrel-ping | `path_simulation` | Traceroute without sockets (BL-0013) | graphs; hashing (how routers split flows across paths) | planned |
//! | quarrel-ping | `clock_sync` | One-way delay and why it is hard (BL-0014) | a small system of equations (offset and delay from four timestamps); error bounds | planned |
//! | quarrel-ping | `latency_anatomy` | Where the milliseconds come from (BL-0015) | queueing: Little's law L = λW; M/M/1 waiting time as a Markov birth–death process | planned |
//!
//! Each module's integration tests live in `tests/<module>.rs`; runnable
//! examples in `examples/` (`cargo run -p quarrel-lessons --example <name>`).

pub mod checked_arithmetic;
