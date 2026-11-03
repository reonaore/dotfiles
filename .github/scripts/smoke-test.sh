#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nvim_config="$HOME/.config/nvim"
nvim_assert="$script_dir/nvim-assert.lua"
tmux_config="$HOME/.config/tmux/tmux.conf"
tmux_plugins="$HOME/.local/share/tmux/plugins"
tpm="$tmux_plugins/tpm"

for required_file in \
  "$nvim_config/init.lua" \
  "$nvim_config/lazy-lock.json" \
  "$nvim_config/lua/autocmds.lua"; do
  if [ ! -f "$required_file" ]; then
    echo "Missing Neovim bootstrap file: $required_file" >&2
    exit 1
  fi
done

echo "Restoring locked Neovim plugins"
mise exec -- nvim --headless "+Lazy! restore" "+luafile $nvim_assert"

echo "Checking a second headless Neovim startup"
mise exec -- nvim --headless "+luafile $nvim_assert"

if [ ! -x "$tpm/bin/install_plugins" ]; then
  echo "TPM installer is missing: $tpm/bin/install_plugins" >&2
  exit 1
fi

echo "Installing tmux plugins"
"$tpm/bin/install_plugins"

plugin_count=0
while IFS= read -r plugin; do
  plugin_count=$((plugin_count + 1))
  plugin_name="${plugin##*/}"
  plugin_name="${plugin_name%.git}"
  if [ ! -d "$tmux_plugins/$plugin_name" ]; then
    echo "tmux plugin was not installed: $plugin" >&2
    exit 1
  fi
done < <(
  sed -n -E \
    "s/^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+@plugin[[:space:]]+['\"]([^'\"]+)['\"].*/\2/p" \
    "$tmux_config"
)

if [ "$plugin_count" -eq 0 ]; then
  echo "No tmux plugins were found in $tmux_config" >&2
  exit 1
fi

socket_name="dotfiles-ci-$$"
cleanup() {
  tmux -L "$socket_name" kill-server >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Starting tmux with the installed configuration"
tmux -L "$socket_name" -f "$tmux_config" new-session -d -s smoke
tmux -L "$socket_name" has-session -t smoke
tmux -L "$socket_name" list-sessions
