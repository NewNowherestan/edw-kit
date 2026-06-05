# edw-kit

`edw-kit` is a personal macOS/Linux bootstrap kit managed with GNU Stow.

## Layout

- `brew/` tiered Brewfiles (`tier1`, `tier2`, `tier3`)
- `dotfiles/tier1` and `dotfiles/tier2` mirror `$HOME` directly
- `docs/` printable command cards/memos
- `submodules/vimfiles` points to `https://github.com/DiskoGoth/vimfiles`
- `dotfiles/hosts/<hostname>` optional host-specific overlay

## Install

Bootstrap a fresh macOS machine (installs Homebrew if needed):

```bash
./bootstrap.sh
```

Default install is tier 1:

```bash
./install.sh
```

Explicit tier:

```bash
./install.sh 2
./install.sh 3
```

Tier cascade is automatic:

- tier 1: console
- tier 2: tier 1 + workstation
- tier 3: tier 1 + tier 2 + full

The installer is idempotent (`brew bundle` + `stow --restow`) and writes logs to `~/.local/state/edw-kit/install.log`.

## Maintenance helpers

```bash
./scripts/lock-brewfiles.sh
./scripts/secrets-bootstrap.sh
```
