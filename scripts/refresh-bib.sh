#!/usr/bin/env bash
# Pull the Zotero library into references.bib via Better BibTeX's local endpoint.
#
# Requires: Zotero running on this machine with the Better BibTeX plugin.
# This is the manual/scriptable path. For hands-off updates, also enable
# "Keep updated" on a Better BibTeX export (see docs/bibliography.md).

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/references.bib"
LIBRARY="${ZOTERO_LIBRARY_ID:-1}"
TRANSLATOR="${ZOTERO_TRANSLATOR:-biblatex}"
ENDPOINT="http://127.0.0.1:23119/better-bibtex/export/library?/${LIBRARY}/library.${TRANSLATOR}"

if ! curl -sf -m 5 -o /dev/null http://127.0.0.1:23119/connector/ping; then
  echo "error: Zotero is not running (no response on 127.0.0.1:23119)." >&2
  echo "       Start Zotero, then re-run this script." >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

if ! curl -sf -m 60 -o "$TMP" "$ENDPOINT"; then
  echo "error: Better BibTeX export failed. Is the plugin installed and enabled?" >&2
  exit 1
fi

# Refuse to clobber a good file with an error page or an empty export.
if ! grep -q '^@' "$TMP"; then
  echo "error: export returned no BibTeX entries; leaving $OUT untouched." >&2
  head -3 "$TMP" >&2
  exit 1
fi

mv "$TMP" "$OUT"
trap - EXIT

echo "references.bib updated: $(grep -c '^@' "$OUT") entries, library $LIBRARY, $TRANSLATOR"
