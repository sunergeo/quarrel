use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::error::Error;
use std::fs::{self, File};
use std::io::{ErrorKind, Write};
use std::path::Path;

#[derive(Serialize, Deserialize, Default)]
pub struct State {
    pub offsets: HashMap<String, u64>,
}

impl State {
    pub fn load(path: &Path) -> Result<State, Box<dyn Error>> {
        match fs::read_to_string(path) {
            Ok(text) => {
                let state: State = serde_json::from_str(&text)?;
                Ok(state)
            }
            Err(e) if e.kind() == ErrorKind::NotFound => Ok(State::default()),
            Err(e) => Err(e.into()),
        }
    }
    pub fn save(&self, path: &Path) -> Result<(), Box<dyn Error>> {
        let text = serde_json::to_string_pretty(self)?;

        let tmp = path.with_extension("json.tmp");

        let mut file = File::create(&tmp)?;
        file.write_all(text.as_bytes())?;
        file.sync_all()?;

        fs::rename(&tmp, path)?;

        //Sync the directory too, just in case none was specified...
        let dir = match path.parent() {
            Some(p) if !p.as_os_str().is_empty() => p,
            _ => Path::new("."), // a bare "state.json" lives in the current directory
        };
        File::open(dir)?.sync_all()?;

        Ok(())
    }
}
