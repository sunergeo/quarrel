//! Tests for quarrel_shipper::state.

use quarrel_shipper::state::State;

#[test]
fn first_run_with_no_state_file_starts_empty() -> Result<(), Box<dyn std::error::Error>> {
    let dir = tempfile::tempdir()?;
    let path = dir.path().join("state.json"); // a PathBuf; the file doesn't exist

    let state = State::load(&path)?;

    assert!(state.offsets.is_empty());
    Ok(())
}

#[test]
fn saved_state_loads_back_and_leaves_no_temp_file() -> Result<(), Box<dyn std::error::Error>> {
    let dir = tempfile::tempdir()?;
    let path = dir.path().join("state.json"); // a PathBuf; the file doesn't exist

    let mut state = State::default();

    state.offsets.insert("/tmp/x.log".to_string(), 14);

    state.save(&path)?;
    let loaded = State::load(&path)?;

    assert!(!dir.path().join("state.json.tmp").exists());
    assert_eq!(loaded.offsets.get("/tmp/x.log"), Some(&14));

    Ok(())
}
