//! The day-2 warm-up, unchanged except that `factorial` and `product` now live
//! in the lessons library (`src/checked_arithmetic.rs`) where they're tested.
//!
//! Run it with: `cargo run -p quarrel-lessons --example factorial`

use quarrel_lessons::checked_arithmetic::{factorial, product};

fn main() {
    let x: [f64; 0] = [];
    println!("Product: {:?}: {}", x, product(&x));

    let r = [1.0, 2.24, 5.1, 12.1];
    let p = product(&r);
    println!("Product: {:?}: {}", r, p);

    let n = 1000;

    for k in 1..=n {
        let res: Option<u64> = factorial(k);
        match res {
            Some(value) => {
                println!("Factorial {k}: {value}");
            }
            None => {
                println!("Factorial {k} overflow");
                break;
            }
        }
    }
}
