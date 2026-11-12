use std::fs::File;
use std::io::{self, Read};
use std::path::Path;

use sha2::{Digest, Sha256};

#[derive(Default)]
pub struct Fingerprint {
    pub hash: String, // "sha256:<hex>", the same shape the ingest contract uses for file_fp
    pub len: u64,     // how many bytes the hash covers
}

/// Hash the first `max_len` bytes of the file (fewer if the file is shorter).
/// Returns None for an empty file: there's nothing to identify yet.
pub fn fingerprint(path: &Path, max_len: u64) -> io::Result<Option<Fingerprint>> {
    let file = File::open(path)?;
    let mut limited = file.take(max_len);
    let mut buf = Vec::new();
    limited.read_to_end(&mut buf)?;

    if buf.is_empty() {
        return Ok(None);
    }

    let digest = Sha256::digest(&buf);
    let hex: String = digest.iter().map(|b| format!("{:02x}", b)).collect();
    Ok(Some(Fingerprint {
        hash: format!("sha256:{hex}"),
        len: buf.len() as u64,
    }))
}
