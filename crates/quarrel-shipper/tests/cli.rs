//! Tests that run the real `quarrel-shipper` binary, the way an operator would.
//!
//! Cargo builds the binary before running integration tests and tells us where
//! it is through the `CARGO_BIN_EXE_<name>` environment variable.

use std::process::Command;

#[test]
fn version_flag_prints_name_and_version() {
    let output = Command::new(env!("CARGO_BIN_EXE_quarrel-shipper"))
        .arg("--version")
        .output()
        .expect("the quarrel-shipper binary should run");

    assert!(output.status.success());

    let stdout = String::from_utf8(output.stdout).expect("output should be UTF-8");
    assert_eq!(stdout.trim(), format!("quarrel-shipper {}", env!("CARGO_PKG_VERSION")));
}

#[test]
fn runs_and_exits_cleanly_with_no_arguments() {
    let output = Command::new(env!("CARGO_BIN_EXE_quarrel-shipper"))
        .env("QUARREL_ENV", "test")
        .output()
        .expect("the quarrel-shipper binary should run");

    assert!(output.status.success());

    let stdout = String::from_utf8(output.stdout).expect("output should be UTF-8");
    assert!(stdout.contains("(env: test)"), "unexpected output: {stdout}");
}
