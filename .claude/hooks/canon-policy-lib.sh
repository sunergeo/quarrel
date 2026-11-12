# shellcheck shell=bash
# =============================================================================
# canon — shared helpers for the CLIENT-side guards and git hooks (sourced, never run).
#
#   canon_env NAME [default]          CANON_<NAME>, else a legacy ECX_/SUNERGEO_ alias
#   canon_policy_files                the policy layer files, in order (one per line)
#   canon_policy_get KEY CLASS        a policy value, fence-aware; CLASS locked|free
#   canon_repo_top DIR                the work-tree top of DIR (rc!=0 if not a repo)
#   canon_protected_regex DIR         ^(fixed superset|roster trunk|extra)$ for DIR's repo
#   canon_cmd_target_dir CMD          the repo a shell command acts on: `git -C <p>` /
#                                     a leading `cd <p> &&`, else "."
#
# The SERVER hook does not use this file: it reads only the resolved overlay.
#
# POLICY SOURCES. CANON_POLICY_PATH is a ':'-separated list of layer files, most general
# first — normally canon's standard then the org overlay:
#   /srv/org-governance/canon/standards/git-branch-roles.md:/srv/org-governance/org-governance/org.canon-policy
# A legacy single combined doc (ECX_POLICY_PATH / SUNERGEO_POLICY_PATH) also works.
# * Fence-aware: in a Markdown file ONLY lines inside a ```canon-policy fence
#   (or a legacy ```ecx-policy / ```sunergeo-policy fence) are policy; prose never is.
#   Two fences that disagree on a key are a conflict -> no value -> the caller's
#   protective default applies (fail closed).
# * A non-Markdown file is plain key=value (an org overlay or a resolved overlay).
# * LOCKED keys are read from the FIRST file only: a lower layer can never switch a
#   floor off on the client (the resolver refuses such an overlay anyway).
# * FREE keys: the last file that sets the key wins.
# Every function returns 0 on the normal path so a `set -euo pipefail` caller never
# aborts and fails open.
# =============================================================================

canon_env() {  # canon_env NAME [default]
  local n="$1" p v
  for p in CANON ECX SUNERGEO; do
    v="${p}_${n}"
    if [ -n "${!v:-}" ]; then printf '%s' "${!v}"; return 0; fi
  done
  printf '%s' "${2:-}"
}

CANON_DEFAULT_POLICY_PATH="/srv/org-governance/canon/standards/git-branch-roles.md:/srv/org-governance/org-governance/org.canon-policy"
CANON_DEFAULT_ROSTER="/srv/org-governance/org-governance/fleet/repos.json"

canon_policy_files() {
  local list f
  list="$(canon_env POLICY_PATH "$CANON_DEFAULT_POLICY_PATH")"
  local IFS=':'
  for f in $list; do [ -n "$f" ] && printf '%s\n' "$f"; done
  return 0
}

# _canon_file_get FILE KEY -> value (rc 3 = fences conflict, rc 1 = unreadable / unset)
_canon_file_get() {
  local file="$1" key="$2" md=0
  [ -r "$file" ] || return 1
  case "$file" in *.md|*.markdown) md=1 ;; esac
  awk -v key="$key" -v md="$md" '
    BEGIN { infence = ""; anyfence = 0; plain_set = 0 }
    /^```(canon-policy|ecx-policy|sunergeo-policy)[ \t]*$/ {
      infence = $0; sub(/^```/, "", infence); sub(/[ \t]+$/, "", infence); anyfence = 1; next }
    /^```/ { if (infence != "") { infence = ""; next } }
    {
      line = $0; sub(/#.*/, "", line); gsub(/^[ \t]+|[ \t]+$/, "", line)
      i = index(line, "="); if (i < 2) next
      k = substr(line, 1, i - 1); v = substr(line, i + 1)
      if (k != key || v == "") next
      if (infence != "") { if (!(infence in fv)) fv[infence] = v; next }
      if (!md && !plain_set) { plain = v; plain_set = 1 }
    }
    END {
      if (anyfence) {
        distinct = 0; for (f in fv) { if (!(fv[f] in seen)) { seen[fv[f]] = 1; distinct++ } }
        if (distinct > 1) exit 3
        if ("canon-policy" in fv) { print fv["canon-policy"]; exit 0 }
        for (f in fv) { print fv[f]; exit 0 }
        exit 1
      }
      if (plain_set) { print plain; exit 0 }
      exit 1
    }' "$file"
}

canon_policy_get() {  # canon_policy_get KEY [locked|free]
  local key="$1" cls="${2:-free}" f v rc out=""
  while IFS= read -r f; do
    v="$(_canon_file_get "$f" "$key")" && rc=0 || rc=$?
    if [ "$rc" = 3 ]; then out=""; [ "$cls" = locked ] && break; continue; fi
    [ "$rc" = 0 ] && [ -n "$v" ] && out="$v"
    [ "$cls" = locked ] && break               # locked: the first (most general) layer only
  done < <(canon_policy_files)
  printf '%s' "$out"
  return 0
}

canon_repo_top() { git -C "$1" rev-parse --show-toplevel 2>/dev/null; }

# canon_roster_trunk DIR -> the roster `trunk` of the repo containing DIR (empty if unknown)
canon_roster_trunk() {
  local top roster
  top="$(canon_repo_top "$1")" || return 0
  roster="$(canon_env ROSTER "$CANON_DEFAULT_ROSTER")"
  [ -r "$roster" ] && command -v python3 >/dev/null 2>&1 || return 0
  python3 - "$roster" "$(basename "$top")" <<'PY' 2>/dev/null || true
import json, os, sys
try:
    for r in json.load(open(sys.argv[1])).get("repos", []):
        if os.path.basename(r.get("path", "").rstrip("/")) == sys.argv[2] and r.get("trunk"):
            print(r["trunk"]); break
except Exception:
    pass
PY
  return 0
}

# Protected = a FIXED superset (master, release/current|previous|staging) plus the
# roster's trunk where it is not `master`, plus CANON_PROTECTED_EXTRA (space-separated).
canon_protected_regex() {
  local dir="${1:-.}" alt="master|release/(current|previous|staging)" t extra
  t="$(canon_roster_trunk "$dir")"
  extra="$(canon_env PROTECTED_EXTRA "")"
  for b in $t $extra; do
    case "$b" in master|"") ;; *) alt="$alt|$(printf '%s' "$b" | sed 's/[.[\*^$()+?{}|]/\\&/g')" ;; esac
  done
  printf '^(%s)$' "$alt"
}

# canon_cmd_target_dir CMD -> directory the command's git invocation acts on
canon_cmd_target_dir() {
  local cmd="$1" base="." p=""
  local re_cd='^[[:space:]]*cd[[:space:]]+("([^"]+)"|'"'"'([^'"'"']+)'"'"'|([^[:space:];&|]+))[[:space:]]*(&&|;)'
  local re_c='(^|[[:space:];&|(])git[[:space:]]+(-[a-zA-Z][^[:space:]]*[[:space:]]+)*-C[[:space:]]*("([^"]+)"|'"'"'([^'"'"']+)'"'"'|([^[:space:];&|]+))'
  if [[ $cmd =~ $re_cd ]]; then
    base="${BASH_REMATCH[2]}${BASH_REMATCH[3]}${BASH_REMATCH[4]}"
  fi
  if [[ $cmd =~ $re_c ]]; then
    p="${BASH_REMATCH[4]}${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
  fi
  base="${base/#\~/$HOME}"; p="${p/#\~/$HOME}"
  if [ -n "$p" ]; then
    case "$p" in /*) printf '%s' "$p" ;; *) printf '%s/%s' "$base" "$p" ;; esac
  else
    printf '%s' "$base"
  fi
  return 0
}
