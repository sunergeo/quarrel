#!/usr/bin/env bash
# =============================================================================
# canon — PreToolUse EDIT guard (edit.require_branch, worktree.single_writer)
#
# The agent-side, before-it-happens layer that enforces "every change begins on a
# working branch". The agent runner invokes it on every file-mutating tool call
# (matcher: Write|Edit|MultiEdit|NotebookEdit). It resolves the branch of the repo
# that owns the TARGET FILE and denies the edit if that HEAD is on a protected branch
# — so a change can never even start on a protected branch — or if a different live
# actor holds that working tree.
#
# Applies to the main agent and every subagent. Reads the same policy as every other
# layer (canon-policy-lib.sh); never re-encodes the rules. Part of the managed floor.
#
# Contract (PreToolUse):
#   stdin : JSON with .tool_name and .tool_input.{file_path|notebook_path}
#   deny  : print a JSON permissionDecision=deny object, exit 0
#   allow : exit 0 with no decision
# =============================================================================
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=canon-policy-lib.sh
. "$HOOK_DIR/canon-policy-lib.sh"

# FAIL CLOSED: unreadable policy or absent key => enforce. Locked keys come from the
# first (canon) layer only, so an org/repo layer can never switch the floor off here.
REQUIRE="$(canon_policy_get edit.require_branch locked)"; REQUIRE="${REQUIRE:-true}"
SINGLE_WRITER="$(canon_policy_get worktree.single_writer locked)"; SINGLE_WRITER="${SINGLE_WRITER:-true}"
TTL="$(canon_policy_get worktree.lease_ttl_hours free)"; export CANON_LEASE_TTL_HOURS="${TTL:-24}"
LEASE_OK=0
_HELPER="$(canon_env LEASE_HELPER "$HOOK_DIR/canon-worktree-lease.sh")"
if [ -r "$_HELPER" ]; then . "$_HELPER" 2>/dev/null && LEASE_OK=1 || LEASE_OK=0; fi

PAYLOAD="$(cat)"
if command -v jq >/dev/null 2>&1; then
  TOOL="$(jq -r '.tool_name // ""' <<<"$PAYLOAD")"
  FP="$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""' <<<"$PAYLOAD")"
else
  TOOL="$(grep -oE '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' <<<"$PAYLOAD" | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//' || true)"
  FP="$(grep -oE '"(file_path|notebook_path)"[[:space:]]*:[[:space:]]*"[^"]*"' <<<"$PAYLOAD" | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//' || true)"
fi

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' \
    "$(printf '%s' "DENIED by CANON-BRANCH-POLICY: $1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')"
  exit 0
}

# Emergency override (incident use only). Prefer the policy itself.
[ "$(canon_env ALLOW_EDIT_ON_PROTECTED 0)" = "1" ] && exit 0
[ "$REQUIRE" = "true" ] || exit 0
[ -n "$FP" ] || exit 0

# nearest existing directory of a (possibly not-yet-created) path
dir="$FP"
[ -d "$dir" ] || dir="$(dirname "$FP")"
while [ ! -d "$dir" ] && [ "$dir" != "/" ] && [ -n "$dir" ]; do dir="$(dirname "$dir")"; done
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0     # not governed

branch="$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null || echo DETACHED)"
PROTECTED="$(canon_protected_regex "$dir")"
if [[ "$branch" =~ $PROTECTED ]]; then
  deny "refusing ${TOOL:-edit} of '$FP' while its repo is on protected branch '$branch'. Every change begins on a working branch: 'git switch -c feature/<slug>' (or bugfix/*, hotfix/*) off the trunk, edit there, then promote with one clean, fast-forward commit. (Emergency override: CANON_ALLOW_EDIT_ON_PROTECTED=1.)"
fi

if [ "$SINGLE_WRITER" = "true" ] && [ "$LEASE_OK" = "1" ]; then
  if canon_lease_conflict "$dir"; then
    deny "refusing ${TOOL:-edit} of '$FP': its working tree is held by a different live actor ($(canon_lease_holder "$dir" || echo '?')). One writer per tree — STOP and surface: wait for it to release, or work in an isolated worktree ('git worktree add .worktrees/<slug> -b feature/<slug>'). A lease is reclaimable only once its holder is gone (it goes stale after worktree.lease_ttl_hours)."
  else
    canon_lease_acquire "$dir" "$branch" || true
  fi
fi

exit 0
