# How to run

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply reonaore
```

or if curl is not available and wget is available

```bash
sh -c "$(wget -qO- get.chezmoi.io)" -- init --apply reonaore
```
