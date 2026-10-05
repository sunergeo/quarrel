//! Integration tests for `argus::lessons`.
//!
//! Every file in `tests/` is compiled as its own small crate that uses Argus
//! the way any outside code would: through its public API (`pub` items only).
//! Run them with `cargo test`, or keep `bacon test` open while you work.

use argus::lessons::{factorial, product};

#[test]
fn factorial_of_zero_is_one() {
    assert_eq!(factorial(0), Some(1));
}

#[test]
fn largest_factorial_that_fits_in_a_u64() {
    assert_eq!(factorial(20), Some(2_432_902_008_176_640_000));
}

#[test]
fn overflow_is_none_not_a_panic() {
    assert_eq!(factorial(21), None);
    assert_eq!(factorial(1000), None);
}

#[test]
fn empty_product_is_one() {
    assert_eq!(product(&[]), 1.0);
}
