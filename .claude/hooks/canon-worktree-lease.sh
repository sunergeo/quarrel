# shellcheck shell=bash
# =============================================================================
# canon — working-tree lease helper (worktree.single_writer). SOURCED, never run.
#
# At most one actor may hold a working tree's HEAD for mutation (edits and branch
# moves) at a time. The lease records WHICH actor holds WHICH tree+branch; the edit
# guard, the git guard and the git hooks source this file and refuse to edit, switch
# or commit through a tree a DIFFERENT live actor holds.
#
# This file must never `exit`, and every function returns 0 on the normal path (or a
# meaningful rc used inside a conditional), so a non-zero return can never abort a
# `set -euo pipefail` caller and make it fail open.
#
# Ownership vs liveness:
#   * ownership: the lease file says which actor holds this tree;
#   * liveness: authoritatively answered by the environment's session listing, which
#     only the behavioral actor can call. Here liveness is a wall-clock TTL backstop
#     (worktree.lease_ttl_hours, via CANON_LEASE_TTL_HOURS).
#
# THE ID NAMES THE ACTOR, STABLY. A runner injects CANON_SESSION_ID (the conversation
# id — never a project- or space-wide id, which every conversation shares). Without
# one, the fallback is a STABLE per-actor id, `actor:<user>@<host>` — never a
# per-process id: a PPID-based fallback changed on every commit, so the same person's
# second consecutive commit was refused as a foreign lease.
#
# RENAME WINDOW (state-bearing name, standards/layering.md §10.3): every function
# READS canon-worktree.lease AND the legacy ecx-/sunergeo-worktree.lease, WRITES only
# canon-worktree.lease, and treats EITHER present and live-and-foreign as held.
#
#   canon_lease_session_id               -> this actor's id
#   canon_lease_file       <dir>         -> the canon lease path for <dir>'s worktree
#   canon_lease_files      <dir>         -> every lease path that exists (canon first)
#   canon_lease_field      <dir> <key>   -> a field from the canon lease, else a legacy one
#   canon_lease_acquire    <dir> <br>    -> write/refresh this actor's canon lease (rc 0)
#   canon_lease_conflict   <dir>         -> rc 0 iff a DIFFERENT, non-stale actor holds it
# =============================================================================

CANON_LEASE_NAME="canon-worktree.lease"
CANON_LEASE_LEGACY_NAMES="ecx-worktree.lease sunergeo-worktree.lease"

_canon_lease_env() {  # CANON_<n>, else a legacy alias
  local n="$1" p v
  for p in CANON ECX SUNERGEO; do v="${p}_${n}"; [ -n "${!v:-}" ] && { printf '%s' "${!v}"; return 0; }; done
  printf '%s' "${2:-}"
}

canon_lease_session_id() {
  local sid; sid="$(_canon_lease_env SESSION_ID "")"
  if [ -n "$sid" ]; then printf '%s' "$sid"; return 0; fi
  printf 'actor:%s@%s' "${USER:-$(id -un 2>/dev/null || echo unknown)}" "$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo host)"
}

# `--absolute-git-dir` resolves to a LINKED worktree's own git dir, so each worktree
# gets its own lease automatically. rc!=0 when <dir> is not a work tree.
canon_lease_file() {
  local gd; gd="$(git -C "$1" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  printf '%s/%s' "$gd" "$CANON_LEASE_NAME"
}

canon_lease_files() {
  local gd n; gd="$(git -C "$1" rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  for n in $CANON_LEASE_NAME $CANON_LEASE_LEGACY_NAMES; do [ -r "$gd/$n" ] && printf '%s\n' "$gd/$n"; done
  return 0
}

_canon_lease_file_field() { grep -oE "^$2=.*" "$1" 2>/dev/null | head -1 | cut -d= -f2- || true; }

canon_lease_field() {
  local f; f="$(canon_lease_files "$1" 2>/dev/null | head -1)"
  [ -n "$f" ] || return 1
  _canon_lease_file_field "$f" "$2"
}

# Write/refresh this actor's lease. Best-effort: always rc 0. `acquired_at` is the
# FIRST-claim time, kept across refreshes while the same actor holds it.
canon_lease_acquire() {
  local dir="$1" branch="$2" f sid dirty iso prior_acq
  f="$(canon_lease_file "$dir" 2>/dev/null)" || return 0
  sid="$(canon_lease_session_id)"
  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then dirty=true; else dirty=false; fi
  iso="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo '')"
  prior_acq=""
  if [ -r "$f" ] && [ "$(_canon_lease_file_field "$f" session_id)" = "$sid" ]; then
    prior_acq="$(_canon_lease_file_field "$f" acquired_at)"
  fi
  [ -n "$prior_acq" ] || prior_acq="$iso"
  {
    printf 'session_id=%s\n' "$sid"
    printf 'branch=%s\n' "$branch"
    printf 'dirty=%s\n' "$dirty"
    printf 'acquired_at=%s\n' "$prior_acq"
    printf 'last_touch_epoch=%s\n' "$(date +%s 2>/dev/null || echo 0)"
    printf 'last_touch_at=%s\n' "$iso"
    printf 'agent=%s\n' "$(_canon_lease_env AGENT "${USER:-unknown}")"
  } >"$f" 2>/dev/null || true
  return 0
}

_canon_lease_held_by_other() {  # <lease-file> -> rc 0 iff a different, non-stale actor holds it
  local f="$1" holder mine ttl now touched age
  holder="$(_canon_lease_file_field "$f" session_id)"; [ -n "$holder" ] || return 1
  mine="$(canon_lease_session_id)"
  [ "$holder" = "$mine" ] && return 1                       # reentrant: I hold it
  ttl="$(_canon_lease_env LEASE_TTL_HOURS 24)"
  case "$ttl" in ''|*[!0-9]*) ttl=24 ;; esac
  now="$(date +%s 2>/dev/null || echo 0)"
  touched="$(_canon_lease_file_field "$f" last_touch_epoch)"
  case "$touched" in ''|*[!0-9]*) return 0 ;; esac          # garbage timestamp -> FAIL CLOSED (held)
  age=$(( now - touched ))
  [ "$age" -gt $(( ttl * 3600 )) ] && return 1              # stale -> reclaimable
  return 0
}

# rc 0 (conflict) iff ANY lease file present — canon or legacy — is held by a
# different live actor. Two tools reading different names must never both see "free".
canon_lease_conflict() {
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    _canon_lease_held_by_other "$f" && return 0
  done < <(canon_lease_files "$1" 2>/dev/null)
  return 1
}

# canon_lease_holder <dir> -> "session_id branch" of the conflicting lease (for messages)
canon_lease_holder() {
  local f
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if _canon_lease_held_by_other "$f"; then
      printf '%s %s (%s)' "$(_canon_lease_file_field "$f" session_id)" "$(_canon_lease_file_field "$f" branch)" "$(basename "$f")"
      return 0
    fi
  done < <(canon_lease_files "$1" 2>/dev/null)
  return 1
}
