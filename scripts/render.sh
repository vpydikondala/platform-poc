#!/usr/bin/env bash
set -euo pipefail
TEMPL_DIR="${1:-templates}"
OUT_DIR="${2:-rendered}"
mkdir -p "$OUT_DIR"
set -a
# shellcheck disable=SC1090
source poc.env
: "${POSTGRES_ADMIN_PASSWORD:?POSTGRES_ADMIN_PASSWORD env var is required}"
set +a
while IFS= read -r -d '' f; do
  rel="${f#"$TEMPL_DIR"/}"
  out="$OUT_DIR/${rel%.tpl}"
  mkdir -p "$(dirname "$out")"
  envsubst < "$f" > "$out"
done < <(find "$TEMPL_DIR" -type f -name "*.tpl" -print0)
echo "Rendered templates into $OUT_DIR"
