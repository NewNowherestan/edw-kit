# edw-kit

`edw-kit` is a profile-driven bootstrap kit for macOS and Linux.

## Structure-first model

The repository is organized around dotfile profiles instead of script internals:

- `dotfiles/terminal` → shell/editor/terminal baseline
- `dotfiles/workstation` → desktop/workstation layer
- `dotfiles/hosts/<hostname>` → optional machine-specific overrides

Package installation remains split in Brewfile tiers:

- `brew/Brewfile.tier1` (terminal)
- `brew/Brewfile.tier2` (workstation)
- `brew/Brewfile.tier3` (full/macOS extras)

## Entry points

### 1) Bootstrap environment

Use this on fresh machines. It prepares platform prerequisites, installs Homebrew if needed, and then runs the installer:

```bash
./bootstrap.sh
```

Defaults:

- macOS → `workstation`
- Linux → `terminal`

### 2) Apply profiles directly

```bash
./install.sh terminal
./install.sh workstation
./install.sh full
```

You can also use legacy aliases:

```bash
./install.sh 1   # terminal
./install.sh 2   # workstation
./install.sh 3   # full
```

Useful flags:

```bash
./install.sh --profile workstation --dry-run
./install.sh --profile full --skip-brew
./install.sh --profile terminal --skip-stow
```

Installer log:

`~/.local/state/edw-kit/install.log`

## Helper scripts

Lock all Brewfiles:

```bash
./scripts/lock-brewfiles.sh
```

Create local secrets scaffold (non-git):

```bash
./scripts/secrets-bootstrap.sh
```
