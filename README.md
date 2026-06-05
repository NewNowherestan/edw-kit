# edw-kit

`edw-kit` is a personal macOS/Linux bootstrap kit managed with GNU Stow.

## Layout

- `brew/` tiered Brewfiles (`tier1`, `tier2`, `tier3`)
- `dotfiles/tier1` and `dotfiles/tier2` mirror `$HOME` directly
- `docs/` printable command cheatsheets
- `submodules/` reserved for external config repos

## Install

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
