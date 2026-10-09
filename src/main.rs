//! The `argus` binary.
//!
//! Deliberately thin: it reads the command line and hands off to the
//! library (`src/lib.rs`), where the real work lives. Code in the library can
//! be tested directly; code in here can only be tested by running the binary.

use argus::scan::complete_lines;
use std::env;
use std::error::Error;
use std::path::Path;

// `main` can return a `Result`. If it returns `Err`, Rust prints the error and
// exits with a non-zero status, so `?` works here just like inside `factorial`.
fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().skip(1).collect();

    match args.as_slice() {
        [cmd, path] if cmd == "scan" => {
            let path = Path::new(path);
            let counts = complete_lines(path)?;
            for line in &counts.lines {
                println!("{}: {}", line.offset, String::from_utf8_lossy(&line.bytes));
            }
            println!(
                "{} lines, end_offset {}",
                counts.lines.len(),
                counts.end_offset
            );
            return Ok(());
        }
        _ => {
            if args.iter().any(|arg| arg == "--version" || arg == "-V") {
                println!("{}", argus::version_line());
                return Ok(());
            }
        }
    }

    argus::run()
}
