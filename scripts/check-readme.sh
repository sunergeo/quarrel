#!/usr/bin/env bash
# check-readme.sh — catch mechanical drift between README.md and the repository (ADR-0010).
#
# Usage (from anywhere inside the repo):
#   scripts/check-readme.sh
#
# Checks:
#   1. every workspace member (Cargo.toml `members`) appears in the README crate table;
#   2. every planned crate named in Cargo.toml's "(planned)" comments appears there too;
#   3. every crate-table row carries a status label: In development, Planned, or Released vX.Y.Z
#      (quarrel-lessons is exempt: it is never released);
#   4. every relative link in the README resolves to a file or directory.
#
# Exit 0 = no mechanical drift. Exit 1 = drift, with one line per problem.
# It cannot judge whether a true-looking claim is stale; the rollup review does that (ADR-0010 §5).

set -euo pipefail
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
README=README.md
fail=0
problem() { echo "DRIFT: $*"; fail=1; }

[ -f "$README" ] || { echo "DRIFT: $README is missing"; exit 1; }

# The crate table: rows that start with "| `" before the first "## " heading.
table="$(awk '/^## /{exit} /^\| `/{print}' "$README")"

# 1. Workspace members, e.g. members = ["crates/quarrel-shipper", "crates/quarrel-lessons"]
members="$(sed -n 's/^members *= *\[\(.*\)\]/\1/p' Cargo.toml | tr ',' '\n' | tr -d ' "' | sed '/^$/d')"
for m in $members; do
  name="${m##*/}"
  grep -q "\`[^\`]*${name}\`" <<<"$table" || problem "workspace member '$name' is not in the README crate table"
done

# 2. Planned crates, from Cargo.toml comments like:  #   crates/quarrel-ping      (planned) ...
planned="$(sed -n 's/^#[[:space:]]*crates\/\([a-z0-9-]*\)[[:space:]]*(planned).*/\1/p' Cargo.toml)"
for p in $planned; do
  grep -q "\`[^\`]*${p}\`" <<<"$table" || problem "planned crate '$p' is not in the README crate table"
done

# 3. Status labels on every crate row.
while IFS= read -r row; do
  [ -z "$row" ] && continue
  case "$row" in *quarrel-lessons*) continue ;; esac
  if ! grep -Eq '\*\*(In development|Planned)\.?\*\*|\*\*Released v[0-9]+\.[0-9]+\.[0-9]+\.?\*\*' <<<"$row"; then
    problem "crate row has no status label: ${row:0:80}…"
  fi
done <<<"$table"

# 4. Relative links resolve.
grep -oE '\]\([^)#]+\)|src="[^"]+"' "$README" \
  | sed -E 's/^\]\(//; s/\)$//; s/^src="//; s/"$//' \
  | grep -vE '^(https?:|mailto:)' \
  | sort -u \
  | while IFS= read -r link; do
      [ -e "$link" ] || { echo "DRIFT: README link does not resolve: $link"; exit 1; }
    done || fail=1

if [ "$fail" -eq 0 ]; then
  echo "README: no mechanical drift (ADR-0010)."
fi
exit "$fail"
