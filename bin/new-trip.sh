#!/usr/bin/env bash
# Scaffold a new trip page: bin/new-trip.sh <slug> [title]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <slug> [title]" >&2
  exit 1
fi

slug=$1
title=${2:-$slug}
date=$(date +%Y-%m-%d)

repo_root=$(cd "$(dirname "$0")/.." && pwd)
dir="$repo_root/trips/$slug"
file="$dir/index.qmd"

if [[ -e "$dir" ]]; then
  echo "error: trip already exists under trips/" >&2
  exit 1
fi

mkdir -p "$dir"
cat > "$file" <<EOF
---
title: "$title"
subtitle: ""
# Start date of the trip. Drives the order on /trips and whether it files
# under Upcoming or Past, so set it before you publish.
date: "$date"
---

<!--
Cheat sheet (no shortcode braces in here, or they'd be expanded):

  stop TYPE "PLACE"   optional: time= nights= booking= cost= note= url=
    hotel eat ferry drive flight train see   (core)
    ride walk wine                           (activity)
    note todo cost                           (admin — no map link)

  travel MODE "DURATION"   sits between two stops
    drive walk ride train ferry flight

Type the duration in yourself from Google Maps; the map and directions links
are generated. Use ## headings for days. Full guide: _guides/trips.md
-->

## $(date +'%a %-d %b') — day one

{{< stop hotel "Hotel name, Town" nights=1 booking="REF" >}}
EOF

echo "created $file"
