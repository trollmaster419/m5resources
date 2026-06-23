#!/usr/bin/env bash
# Regenerate the Flipper resource Manifest from the actual files in this repo.
# Format:
#   V:0
#   T:<unix timestamp>
#   D:<dir>                  (one per directory, sorted)
#   F:<md5>:<size>:<path>    (one per file, sorted)
# Excludes .git, the Manifest itself, and this script.
set -euo pipefail
cd "$(dirname "$0")"

OUT=Manifest
TMP="$(mktemp)"

{
    echo "V:0"
    echo "T:$(date +%s)"

    # Directories (relative, no leading ./), sorted.
    find . -mindepth 1 -type d -not -path './.git' -not -path './.git/*' \
        | sed 's#^\./##' | LC_ALL=C sort \
        | while IFS= read -r d; do echo "D:$d"; done

    # Files, sorted. Skip .git, Manifest, this script.
    find . -type f -not -path './.git/*' \
        ! -name "$OUT" ! -name "$(basename "$0")" \
        | sed 's#^\./##' | LC_ALL=C sort \
        | while IFS= read -r f; do
            md5="$(md5sum "$f" | cut -d' ' -f1)"
            size="$(stat -c%s "$f")"
            echo "F:$md5:$size:$f"
        done
} > "$TMP"

mv "$TMP" "$OUT"
echo "Wrote $OUT: $(grep -c '^F:' "$OUT") files, $(grep -c '^D:' "$OUT") dirs"
