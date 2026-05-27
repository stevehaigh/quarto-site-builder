#!/usr/bin/env bash
# Build deck artifacts: HTML (Reveal.js), PPTX, and PDF.
#
# Usage:
#   ./build.sh           # render HTML + PPTX (via Quarto), then PDF (via Chrome)
#   ./build.sh --no-pdf  # skip the PDF step (useful if Chrome isn't installed)
#
# Outputs land in _site/decks/lab-meeting-2026-05-14/ alongside the rendered HTML.

set -euo pipefail

NO_PDF=0
[[ "${1:-}" == "--no-pdf" ]] && NO_PDF=1

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
DECK_DIR="$REPO_ROOT/_site/decks/lab-meeting-2026-05-14"
DECK_SRC_DIR="$REPO_ROOT/decks/lab-meeting-2026-05-14"
DECK_SRC="decks/lab-meeting-2026-05-14/index.qmd"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

cd "$REPO_ROOT"

echo "→ Rendering HTML + PPTX via Quarto"
quarto render "$DECK_SRC"

if [[ $NO_PDF -eq 1 ]]; then
  echo "✓ Done (PDF skipped)"
  exit 0
fi

if [[ ! -x "$CHROME" ]]; then
  echo "Chrome not found at: $CHROME"
  echo "Install Google Chrome or rerun with --no-pdf."
  exit 1
fi

# The PDF is written into the source folder so it gets committed and survives
# CI deployment (GitHub's Quarto Action doesn't have Chrome). The `decks/**`
# resource glob in _quarto.yml copies it into _site on the next render.
echo "→ Printing PDF via Chrome headless"
"$CHROME" --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=120000 \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf="$DECK_SRC_DIR/index.pdf" \
  "file://$DECK_DIR/index.html?print-pdf"
cp "$DECK_SRC_DIR/index.pdf" "$DECK_DIR/index.pdf"

echo ""
echo "✓ Built:"
echo "    $DECK_DIR/index.html"
echo "    $DECK_DIR/index.pptx"
echo "    $DECK_SRC_DIR/index.pdf  (also copied into _site/)"
