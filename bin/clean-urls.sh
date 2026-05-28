#!/usr/bin/env bash
# Quarto post-render step: strip "index.html" from internal links so the site
# uses extensionless directory URLs (e.g. /blog/ instead of /blog/index.html).
# Every page is rendered as <dir>/index.html, and GitHub Pages serves <dir>/
# from it, so dropping the filename from links is safe and gives clean URLs.
#
# Reveal.js decks under decks/ are left untouched (self-contained apps).
set -euo pipefail

out="${QUARTO_PROJECT_OUTPUT_DIR:-_site}"

# href/canonical/og:url in HTML + stored URLs in the search/listing indexes:
# ".../index.html" -> ".../" (keeps #frag, ?query).
find "$out" \( -name '*.html' -o -name 'search.json' -o -name 'listings.json' \) \
  -not -path "$out/decks/*" -print0 \
  | xargs -0 perl -pi -e 's{/index\.html(["#?])}{/$1}g'

# sitemap <loc> entries: ".../index.html</loc>" -> ".../</loc>".
[ -f "$out/sitemap.xml" ] && perl -pi -e 's{/index\.html(<)}{/$1}g' "$out/sitemap.xml"

exit 0
