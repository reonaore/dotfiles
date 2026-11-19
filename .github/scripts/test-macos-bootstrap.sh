#!/bin/bash

set -euo pipefail

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT

cat > "$fixture/xcode-select" <<'EOF'
#!/bin/sh
if [ "$1" = --install ]; then
  touch "$HOME/install-requested"
  exit 0
fi
exit 1
EOF

cat > "$fixture/chezmoi" <<'EOF'
#!/bin/sh
touch "$HOME/chezmoi-called"
exit 1
EOF
chmod +x "$fixture/xcode-select" "$fixture/chezmoi"

if HOME="$fixture" PATH="$fixture:/usr/bin:/bin" bash bootstrap-macos.sh > "$fixture/bootstrap.log" 2>&1; then
  echo 'Bootstrap succeeded before Command Line Tools were ready.' >&2
  exit 1
fi
cat "$fixture/bootstrap.log"
grep -qF 'then rerun the macOS bootstrap' "$fixture/bootstrap.log"
test -f "$fixture/install-requested"
test ! -e "$fixture/chezmoi-called"

brew_lookup=$(chezmoi execute-template --source "$PWD" '{{ includeTemplate "find-brew" . }}')
PATH=/usr/bin:/bin /bin/bash -eu -c 'eval "$1"; test -x "$brew_bin"' -- "$brew_lookup"
