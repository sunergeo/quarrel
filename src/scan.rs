use std::fs::File;
use std::io::{self, BufRead, BufReader};
use std::path::Path;

#[derive(Default)]
pub struct Line {
    /// Where the line starts in the file
    pub offset: u64,

    /// The line's raw bytes, minus the trailing \n
    pub bytes: Vec<u8>,
}

#[derive(Default)]
pub struct CompleteLines {
    /// Collection of complete lines read (does not count partially complete lines)
    pub lines: Vec<Line>,

    /// Offset by the number of bytes in the complete lines read ... essentially
    /// a pointer to the starting point for the next read cycle.
    pub end_offset: u64,
}

pub fn complete_lines(path: &Path) -> io::Result<CompleteLines> {
    // Open the file
    let file = File::open(path)?;

    // Wrap it in a BufReader
    let mut reader = BufReader::new(file);

    // Read line by line
    let mut complete_lines = CompleteLines::default();
    let mut buf: Vec<u8> = Vec::new();

    loop {
        let n = reader.read_until(b'\n', &mut buf)?;
        if n == 0 {
            break;
        }

        if buf.ends_with(b"\n") {
            // Remove the trailing \n
            buf.pop();

            complete_lines.lines.push(Line {
                bytes: std::mem::take(&mut buf),
                offset: complete_lines.end_offset,
            });
            complete_lines.end_offset += n as u64;
        }
    }

    Ok(complete_lines)
}
