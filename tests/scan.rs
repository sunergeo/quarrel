//! Tests for argus::scan.

use std::io::Write;
use std::path::Path;

use argus::scan::complete_lines;
use tempfile::NamedTempFile;

#[test]
fn counts_complete_lines() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"one\ntwo\nthree\n")?;

    let counts = complete_lines(file.path())?;

    assert_eq!(counts.lines, 3);
    assert_eq!(counts.end_offset, 14); // 4 + 4 + 6, newlines included
    Ok(())
}

#[test]
fn missing_file_is_an_error() {
    let path = Path::new("/path/to/file/that/does/not/exist");
    let counts = complete_lines(path);
    assert!(counts.is_err());
}

#[test]
fn last_line_without_a_newline() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"a\nb")?;
    let counts = complete_lines(file.path())?;

    assert_eq!(counts.lines, 1);

    // stops before the partial "b": the next read must start there
    assert_eq!(counts.end_offset, 2);

    Ok(())
}
