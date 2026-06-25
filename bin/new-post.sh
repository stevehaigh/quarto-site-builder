#!/usr/bin/env bash
# Scaffold a new blog post: bin/new-post.sh <slug> [title]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <slug> [title]" >&2
  exit 1
fi

slug=$1
title=${2:-$slug}
date=$(date +%Y-%m-%d)

repo_root=$(cd "$(dirname "$0")/.." && pwd)
dir="$repo_root/blog/drafts/$slug"
file="$dir/index.qmd"

if [[ -e "$repo_root/blog/posts/$slug" || -e "$repo_root/blog/drafts/$slug" ]]; then
  echo "error: post already exists under blog/posts/ or blog/drafts/" >&2
  exit 1
fi

mkdir -p "$dir"
cat > "$file" <<EOF
---
title: "$title"
description: ""
author: "Steve Haigh"
date: "$date"
categories: []
draft: true
---

EOF

echo "created $file"
