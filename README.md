# How to apply

## macOS

Run this from Terminal.

```bash
bootstrap=$(curl -fsSL https://raw.githubusercontent.com/reonaore/dotfiles/main/bootstrap-macos.sh) &&
  /bin/bash -c "$bootstrap"
```

If Apple opens the Command Line Tools installer, finish the installation and
rerun the same command. When Homebrew is missing on Apple Silicon, setup runs
the official Homebrew installer and may prompt for your password. Intel Macs
require an existing Homebrew installation.

## Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply reonaore
```

or if curl is not available and wget is available

```bash
sh -c "$(wget -qO- get.chezmoi.io)" -- init --apply reonaore
```

# After applying

```bash
chsh -s "$(which zsh)"
```

Restart the terminal (or run `exec zsh`) to load the configuration from
`$ZDOTDIR`.
