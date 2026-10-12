#!/usr/bin/env bash
# Copy the newest generated figures into figures/ under the stable names that
# main.tex cites. Driven by figures/figures.manifest.
#
# Why this exists: analysis output is date-stamped (eod_angle_sweep_2026-04-01_*.png),
# but \includegraphics must point at a filename that never changes, or every new
# run would require editing the manuscript. This script is the bridge.
#
# Usage:  scripts/refresh-figures.sh [--dry-run]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIGDIR="$REPO/figures"
MANIFEST="$FIGDIR/figures.manifest"

# Where generated figures are produced. Add roots here as analysis moves around.
#
# The NAS roots are where the Julia analysis scripts write their output (they
# save back next to the data they read). A root that is not mounted is skipped,
# not an error: once a figure has been copied here and committed, every other
# machine builds from the committed copy and never needs the NAS at all.
NAS="Y:/Projects/NSF-MINFLUX/projects/Data/Evaluation Experiments/EOD Driver test"
SOURCE_ROOTS=(
  "$REPO/../project-nsf-minflux/project-log/figures"
  "$REPO/../Honors_physics_paper/figures/eod"
  "$REPO/../Honors_physics_paper/figures/donut"
  "$REPO/../Honors_physics_paper/figures/galvo"
  "$REPO/../Honors_physics_paper/figures/final"
  "$NAS/beam characterizatiom/gausian/jun2"
  "$NAS/beam characterizatiom/angle/apr_1"
  "$NAS/figures"
)

DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

[ -f "$MANIFEST" ] || { echo "error: no manifest at $MANIFEST" >&2; exit 1; }
mkdir -p "$FIGDIR"

updated=0; unchanged=0; missing=0

while read -r stable glob; do
  case "$stable" in ''|\#*) continue ;; esac
  [ -z "${glob:-}" ] && continue

  # Newest match across all source roots.
  newest=""
  for root in "${SOURCE_ROOTS[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      if [ -z "$newest" ] || [ "$f" -nt "$newest" ]; then newest="$f"; fi
    done < <(find "$root" -maxdepth 1 -name "$glob" -type f 2>/dev/null)
  done

  if [ -z "$newest" ]; then
    echo "  MISSING  $stable  (no match for '$glob')"
    missing=$((missing+1))
    continue
  fi

  dest="$FIGDIR/$stable"
  if [ -f "$dest" ] && cmp -s "$newest" "$dest"; then
    unchanged=$((unchanged+1))
    continue
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  WOULD    $stable  <-  $(basename "$newest")"
  else
    cp -- "$newest" "$dest"
    echo "  UPDATED  $stable  <-  $(basename "$newest")"
  fi
  updated=$((updated+1))
done < "$MANIFEST"

echo
echo "updated $updated, unchanged $unchanged, missing $missing"
[ "$missing" -gt 0 ] && echo "note: missing entries are listed above; the manuscript will not build until those figures exist or the manifest is corrected." >&2
exit 0
