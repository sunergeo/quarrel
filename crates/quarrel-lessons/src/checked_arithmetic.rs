//! Checked arithmetic: overflow is an error you handle, not a surprise.
//!
//! The first warm-ups (roadmap Stage 1). The shipper never calls these; the
//! habits they teach are the ones it runs on: checked arithmetic instead of
//! silent overflow (its byte offsets), and `Option` plus `?` instead of panics.
//!
//! The lines starting with `///` are documentation. A fenced code block inside
//! them is a *doc test*: `cargo test` compiles and runs it, so the examples in
//! the docs can never drift out of date.

/// `n!`, or `None` if it doesn't fit in a `u64` (anything above 20!).
///
/// `checked_mul` returns `None` on overflow instead of panicking (debug) or
/// wrapping silently (release), and `?` returns that `None` straight out of
/// the function.
///
/// ```
/// use quarrel_lessons::checked_arithmetic::factorial;
///
/// assert_eq!(factorial(5), Some(120));
/// assert_eq!(factorial(21), None); // 21! > u64::MAX
/// ```
pub fn factorial(n: u64) -> Option<u64> {
    let mut prod: u64 = 1;
    for k in 1..=n {
        prod = prod.checked_mul(k)?;
    }

    Some(prod)
}

/// The product of every number in a slice. The empty product is `1.0`.
///
/// `&[f64]` is a *slice*: a borrowed view of some `f64`s. It accepts an array,
/// a `Vec` or part of either, without taking ownership of them.
///
/// ```
/// use quarrel_lessons::checked_arithmetic::product;
///
/// assert_eq!(product(&[2.0, 3.0, 4.0]), 24.0);
/// ```
pub fn product(xs: &[f64]) -> f64 {
    xs.iter().product()
}
