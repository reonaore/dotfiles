#!/bin/bash

set -euo pipefail

if [[ $(uname -s) != Darwin ]]; then
  echo 'This bootstrap is for macOS. See the README for Linux setup.' >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  if ! xcode-select --install; then
    echo 'If the Apple installer did not open, run xcode-select --install from Terminal.' >&2
  fi
  echo 'Finish installing the Xcode Command Line Tools, then rerun the macOS bootstrap.' >&2
  exit 1
fi

if ! /usr/bin/git --version >/dev/null; then
  echo 'Get Git working with the selected Xcode or Command Line Tools, then rerun the macOS bootstrap.' >&2
  exit 1
fi

bin_dir="$HOME/.local/bin"
export PATH="$PATH:$bin_dir"
if ! chezmoi_bin=$(command -v chezmoi); then
  mkdir -p "$bin_dir"
  installer=$(curl -fsSL https://get.chezmoi.io)
  /bin/sh -c "$installer" -- -b "$bin_dir"
  chezmoi_bin="$bin_dir/chezmoi"
fi

exec "$chezmoi_bin" init --apply reonaore "$@"
