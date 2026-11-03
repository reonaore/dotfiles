#!/usr/bin/env bash

set -euo pipefail

source_dir="${1:?usage: assert-chezmoi-clean.sh SOURCE_DIR}"
diff_output="$(chezmoi diff --source "$source_dir" --no-pager)"

if [ -n "$diff_output" ]; then
  echo "chezmoi-managed files differ from the source state:" >&2
  printf '%s\n' "$diff_output" >&2
  exit 1
fi
