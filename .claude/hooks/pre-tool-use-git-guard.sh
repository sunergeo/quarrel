#!/usr/bin/env bash
# =============================================================================
# canon — PreToolUse git/bash guard
#
# The agent-side, before-it-happens layer. The agent runner invokes it on every Bash
# tool call (matcher: Bash). It inspects the proposed command and denies, BEFORE they
# happen:
#   * unconfirmed deletions — rm/rmdir/unlink, git rm, git clean, git worktree
#     remove|prune|move, filter-branch/filter-repo, find -delete, and DESTRUCTIVE mv
#     (mv -f/--force, or a simple mv whose destination exists) — delete.require_confirm
#   * a branch switch through a working tree a different live actor holds
#   * an agent commit without the org's agent identity (agent.author_domain)
#   * a commit on a protected branch; a force-push of a protected ref; a --no-ff merge
#     into the trunk
#
# THE TARGET REPO IS THE ONE THE COMMAND ACTS ON: `git -C <path>`
# and a leading `cd <path> &&` / `cd <path>;` are honoured; otherwise the hook's cwd.
# Best-effort string inspection: the server gate is the real backstop.
#
# Contract (PreToolUse): stdin JSON with .tool_input.command; deny = JSON
# permissionDecision=deny + exit 0; allow = exit 0 with no decision.
# =============================================================================
set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=canon-policy-lib.sh
. "$HOOK_DIR/canon-policy-lib.sh"

# Locked floors come from the first (canon) layer only and FAIL CLOSED when unreadable.
DELETE_CONFIRM="$(canon_policy_get delete.require_confirm locked)"; DELETE_CONFIRM="${DELETE_CONFIRM:-true}"
SINGLE_WRITER="$(canon_policy_get worktree.single_writer locked)"; SINGLE_WRITER="${SINGLE_WRITER:-true}"
ADD_ALLOWED="$(canon_policy_get worktree.add_allowed free)"; ADD_ALLOWED="${ADD_ALLOWED:-true}"
TTL="$(canon_policy_get worktree.lease_ttl_hours free)"; export CANON_LEASE_TTL_HOURS="${TTL:-24}"
# Agent identity is an L1 value with NO canon default: unset means "cannot classify",
# and agent commits are refused rather than tagged with someone else's identity.
AGENT_DOMAIN="$(canon_policy_get agent.author_domain free)"
AGENT_TRAILER="$(canon_policy_get agent.trailer_key free)"
LEASE_OK=0
_HELPER="$(canon_env LEASE_HELPER "$HOOK_DIR/canon-worktree-lease.sh")"
if [ -r "$_HELPER" ]; then . "$_HELPER" 2>/dev/null && LEASE_OK=1 || LEASE_OK=0; fi

PAYLOAD="$(cat)"
if command -v jq >/dev/null 2>&1; then
  CMD="$(jq -r '.tool_input.command // ""' <<<"$PAYLOAD")"
else
  CMD="$(grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' <<<"$PAYLOAD" | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//' || true)"
fi

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' \
    "$(printf '%s' "DENIED by CANON-BRANCH-POLICY: $1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/^/"/; s/$/"/')"
  exit 0
}

CONFIRMED="$(canon_env CONFIRM_DELETE 0)"
ASK="tell the operator exactly WHAT and WHY, get explicit approval, then re-run with CANON_CONFIRM_DELETE=1. Do NOT route around it (no worktree, reset/checkout or mv tricks)."

# --- deletion gate: runs before the "not a git command" exit, so plain-shell removals
#     are policed too. A deny means STOP AND ASK. -------------------------------------
if [ "$DELETE_CONFIRM" = "true" ] && [ "$CONFIRMED" != "1" ]; then
  grep -qE '\bgit\b[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?rm\b' <<<"$CMD" && deny "'git rm' deletes tracked files: $ASK"
  grep -qE '\bgit\b[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?clean\b' <<<"$CMD" && deny "'git clean' irrecoverably deletes untracked files: $ASK"
  grep -qE '\bgit\b[[:space:]]+(-C[[:space:]]+[^[:space:]]+[[:space:]]+)?worktree[[:space:]]+(remove|prune|move)\b' <<<"$CMD" \
    && deny "'git worktree remove/prune/move' removes files: $ASK (additive 'git worktree add' is governed by worktree.add_allowed)"
  grep -qE '\bgit\b.*\b(filter-branch|filter-repo)\b' <<<"$CMD" \
    && deny "history-rewriting deletion (filter-branch/filter-repo) destroys commits: $ASK Deleting history is normally forbidden — archive instead."
  grep -qE '(^|[;&|`(/[:space:]])(rm|rmdir|unlink)([[:space:]]|$)' <<<"$CMD" \
    && deny "file deletion ('rm'/'rmdir'/'unlink') is gated: $ASK (Deleting history/outcomes is forbidden — archive instead.)"
  grep -qE '\bfind\b.*-delete\b' <<<"$CMD" && deny "'find ... -delete' removes files in bulk: $ASK"
  # Destructive mv = a delete in disguise. A rename to a NEW path is allowed.
  if grep -qE '(^|[;&|`(]|[[:space:]])mv([[:space:]]|$)' <<<"$CMD"; then
    if grep -qE '(^|[[:space:]])mv([[:space:]][^;&|]*)?[[:space:]](-f|--force)([[:space:]]|=|$)' <<<"$CMD"; then
      deny "'mv -f/--force' overwrites the destination — a delete-in-disguise: $ASK"
    fi
    # best-effort: ONE simple `mv SRC DEST` (no shell operators, globs or quotes)
    if ! grep -qE '[;&|`(){}<>*?"'"'"']' <<<"$CMD"; then
      read -r -a _argv <<<"$CMD" || _argv=()
      if [ "${_argv[0]:-}" = "mv" ]; then
        _paths=(); for _t in "${_argv[@]:1}"; do case "$_t" in -*) : ;; *) _paths+=("$_t") ;; esac; done
        if [ "${#_paths[@]}" = "2" ]; then
          _src="${_paths[0]}"; _dst="${_paths[1]}"
          [ -f "$_dst" ] && deny "this 'mv' would overwrite the existing file '$_dst' — a delete-in-disguise: $ASK"
          if [ -d "$_dst" ] && [ -e "$_dst/$(basename "$_src")" ]; then
            deny "this 'mv' would overwrite '$_dst/$(basename "$_src")' — a delete-in-disguise: $ASK"
          fi
        fi
      fi
    fi
  fi
fi

case "$CMD" in *git*) : ;; *) exit 0 ;; esac

TARGET="$(canon_cmd_target_dir "$CMD")"
[ -d "$TARGET" ] || TARGET="."
cur_branch() { git -C "$TARGET" symbolic-ref --short -q HEAD 2>/dev/null || echo "DETACHED"; }
PROTECTED="$(canon_protected_regex "$TARGET")"
PROT_ALT="${PROTECTED#^(}"; PROT_ALT="${PROT_ALT%)\$}"

# --- worktree creation is additive and sanctioned unless disabled ------------------
if [ "$ADD_ALLOWED" != "true" ] && grep -qE '\bgit\b.*\bworktree[[:space:]]+(add|list)\b' <<<"$CMD"; then
  deny "git worktree is disabled here (worktree.add_allowed=false)."
fi

# --- single-writer: never move the HEAD of a tree a different live actor holds ----
if [ "$SINGLE_WRITER" = "true" ] && [ "$LEASE_OK" = "1" ] && grep -qE '\bgit\b.*\b(switch|checkout)\b' <<<"$CMD"; then
  if canon_lease_conflict "$TARGET"; then
    deny "the working tree at '$TARGET' is held by a different live actor ($(canon_lease_holder "$TARGET" || echo '?')). Do NOT switch its HEAD out from under it. STOP and surface: wait, or open an isolated worktree ('git worktree add .worktrees/<slug> -b feature/<slug>')."
  else
    tb="$(awk '{for(i=1;i<=NF;i++) if($i=="switch"||$i=="checkout"){j=i+1; while(j<=NF && $j ~ /^-/) j++; print $j; exit}}' <<<"$CMD")"
    canon_lease_acquire "$TARGET" "${tb:-unknown}" || true
  fi
fi

if grep -qE '\bgit\b.*\bcommit\b' <<<"$CMD"; then
  # --- agent commits must be attributable, so the server and audit can classify them
  if [ -z "$AGENT_DOMAIN" ]; then
    deny "agent.author_domain is not set in the policy (it is required at the org layer, L1, and has no canon default), so this commit could not be classified as agent-authored. Point CANON_POLICY_PATH at canon's standard plus the org overlay. Failing closed."
  fi
  email="$(git -C "$TARGET" config user.email 2>/dev/null || echo "")"
  case "$email" in
    *@"$AGENT_DOMAIN") : ;;
    *) deny "agent commits must be authored with an @${AGENT_DOMAIN} email so they are classifiable; '$TARGET' has user.email='${email:-unset}'. Set it (git -C '$TARGET' config user.email <agent>@${AGENT_DOMAIN}). The '${AGENT_TRAILER:-<agent.trailer_key>}:' trailer belongs on the commit too, but a trailer alone does NOT satisfy this check." ;;
  esac
  # --- never commit directly on a protected branch
  b="$(cur_branch)"
  if [[ "$b" =~ $PROTECTED ]]; then
    deny "direct commit on protected branch '$b' in '$TARGET'. Branch to feature/*, bugfix/* or hotfix/* and promote (one clean, fast-forward commit)."
  fi
fi

# --- never force-push a protected ref --------------------------------------------
if grep -qE '\bgit\b.*\bpush\b' <<<"$CMD"; then
  if grep -qE -- '(--force(-with-lease)?|[[:space:]]-f([[:space:]]|$)|[[:space:]]\+)' <<<"$CMD"; then
    # release/staging may be repointed for an RC re-cut where release.staging_allow_force allows it
    STAGING_FORCE="$(canon_policy_get release.staging_allow_force free)"
    FORCE_ALT="$PROT_ALT"; [ "${STAGING_FORCE:-false}" = "true" ] && FORCE_ALT="${FORCE_ALT/|staging)/)}"
    if grep -qE "(^|[[:space:]:+])(refs/heads/)?(${FORCE_ALT})([[:space:]:]|$)" <<<"$CMD"; then
      deny "force-push to a protected ref is forbidden (protected: ${FORCE_ALT}); these refs are advance-only."
    fi
  fi
fi

# --- no merge commits onto the trunk ----------------------------------------------
if grep -qE '\bgit\b.*\bmerge\b' <<<"$CMD"; then
  b="$(cur_branch)"
  if [[ "$b" =~ $PROTECTED ]] && [[ "$b" != release/* ]] && grep -qE -- '--no-ff' <<<"$CMD"; then
    deny "merge into '$b' must be --ff-only; --no-ff would create a merge commit (one clean commit per feature)."
  fi
fi

exit 0
