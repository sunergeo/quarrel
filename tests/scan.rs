//! Tests for argus::scan.

use std::io::Write;
use std::path::Path;

use argus::scan::complete_lines;
use argus::scan::complete_lines_from;
use tempfile::NamedTempFile;

#[test]
fn counts_complete_lines() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"one\ntwo\nthree\n")?;

    let result = complete_lines(file.path())?;

    assert_eq!(result.lines.len(), 3);
    assert_eq!(result.end_offset, 14); // 4 + 4 + 6, newlines included
    Ok(())
}

#[test]
fn missing_file_is_an_error() {
    let path = Path::new("/path/to/file/that/does/not/exist");
    let result = complete_lines(path);
    assert!(result.is_err());
}

#[test]
fn last_line_without_a_newline() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"a\nb")?;
    let result = complete_lines(file.path())?;

    assert_eq!(result.lines.len(), 1);

    // stops before the partial "b": the next read must start there
    assert_eq!(result.end_offset, 2);

    Ok(())
}

#[test]
fn each_line_records_where_it_starts() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"one\ntwo\nthree\nfour\n")?;

    let result = complete_lines(file.path())?;

    assert_eq!(result.lines.len(), 4);
    assert_eq!(result.lines[2].bytes, b"three");
    assert_eq!(result.lines[2].offset, 8);

    Ok(())
}

#[test]
fn read_file_from_the_middle() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"one\ntwo\nthree\nfour\n")?;

    let result = complete_lines_from(file.path(), 8)?;

    assert_eq!(result.lines.len(), 2);
    assert_eq!(result.lines[0].bytes, b"three");
    assert_eq!(result.lines[0].offset, 8);
    assert_eq!(result.end_offset, 19);

    Ok(())
}

#[test]
fn a_line_finished_later_is_read_whole() -> std::io::Result<()> {
    let mut file = NamedTempFile::new()?;
    file.write_all(b"a\nb")?; // "b" is still being written
    let first = complete_lines_from(file.path(), 0)?;

    assert_eq!(first.lines.len(), 1);
    assert_eq!(first.lines[0].bytes, b"a");
    assert_eq!(first.end_offset, 2);

    file.write_all(b"c\n")?; // the writer finishes the line
    let second = complete_lines_from(file.path(), first.end_offset)?;
    assert_eq!(second.lines.len(), 1);
    assert_eq!(second.lines[0].bytes, b"bc");
    assert_eq!(second.lines[0].offset, 2);
    assert_eq!(second.end_offset, 5);

    Ok(())
}
