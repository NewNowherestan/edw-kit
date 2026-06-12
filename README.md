# edw-kit

Profile-driven environment bootstrap for macOS (and a usable subset on Linux).
One repo, one command, and a fresh machine gets shell, terminal tooling, and
desktop apps — managed by **tier**, not by app.

## The tier model

Profiles are cumulative lists of tiers; each profile includes everything
below it:

| Profile       | Tiers applied                             | Platforms     |
|---------------|-------------------------------------------|---------------|
| `shell`       | shell                                     | macOS, Linux  |
| `terminal`    | shell + terminal                          | macOS, Linux  |
| `workstation` | shell + terminal + workstation            | macOS         |
| `full`        | shell + terminal + workstation + full     | macOS         |

A tier is one self-contained directory — its packages, its dotfiles, and its
hooks live together:

```
tiers/<name>/
  Brewfile          packages for this tier (Brewfile.extras etc. also applied)
  dotfiles/         stowed into $HOME, mirroring its layout
  before.sh         optional hook, runs before packages
  after.sh          optional hook, runs after stow (e.g. App Store installs)
  macos-only        optional marker: skip this whole tier on Linux
```

`hosts/<hostname>/` has the exact same shape and is applied last when a
directory matching the machine's hostname exists — per-machine overrides
without forking the kit.

## Daily use

```bash
git pull && make sync
```

`sync` updates submodules, then re-applies the **highest profile this machine
has ever installed** (recorded in `~/.local/state/edw-kit/profile`). If you
ever ran `workstation` here, sync keeps you aligned up to workstation.

## Fresh machine

Installs Xcode CLT / Rosetta / Homebrew as needed, then the default profile
(`workstation` on macOS, `terminal` on Linux):

```bash
./bootstrap.sh
```

## Applying profiles explicitly

```bash
./install.sh terminal          # or: make terminal
./install.sh workstation
./install.sh full

./install.sh --profile workstation --dry-run    # print steps, change nothing
./install.sh --profile full --skip-brew         # dotfiles only
./install.sh --profile terminal --skip-stow     # packages only
```

Numeric aliases still work: `./install.sh 1` = terminal, `2` = workstation,
`3` = full. Run bare `make` to list all targets.

## Repository layout

```
bootstrap.sh         fresh-machine entry point (prereqs + brew → install.sh)
install.sh           profile → tier lists + CLI; thin by design
lib/
  common.sh          logging, dry-run, run_step plumbing
  steps.sh           the tier engine: apply_tier = hooks + brew + stow
tiers/
  shell/             oh-my-zsh core (submodule)
  terminal/          CLI tools + .zshrc, .tmux.conf, .vimrc, starship, omz plugins
  workstation/       ghostty, karabiner, aerospace, fonts (macOS-only)
  full/              GUI + App Store apps (macOS-only)
hosts/<hostname>/    per-machine overlay tier (optional)
scripts/
  sync.sh            daily re-align (make sync)
  doctor.sh          health check: binaries, symlinks, submodules
  reload-env.sh      reload configs in running tmux/ghostty/direnv
  macos-defaults.sh  opinionated macOS performance defaults (manual, opt-in)
  lock-brewfiles.sh  regenerate Brewfile.lock.json files
  secrets-bootstrap.sh  local (non-git) secrets scaffold
docs/cheatsheets/    vim, tmux, aliases, tools quick references
usr/                 taskwarrior data (TASKDATA via .envrc)
```

## Maintenance recipes

**Add a CLI tool** — add a `brew "name"  # why` line to the lowest tier
Brewfile where it belongs, then `make sync`. Candidate apps live as
commented lines in the Brewfiles — uncomment to adopt.

**Add a dotfile** — place it under `tiers/<tier>/dotfiles/` mirroring its
path relative to `$HOME` (e.g. `tiers/terminal/dotfiles/.config/foo/bar.toml`
→ `~/.config/foo/bar.toml`), then `make sync`.

**Machine-specific config** — create `hosts/$(hostname -s)/` with the same
tier shape; it is applied after the profile tiers.

**Tier needs setup logic** — drop a `before.sh` / `after.sh` into the tier;
hooks may source `lib/common.sh` + `lib/steps.sh` for `log` / `run_step` /
`mas_install` (see `tiers/full/after.sh`).

**After editing configs** — `make reload` nudges running tmux/ghostty;
zsh changes need `exec zsh`.

**Something feels off** — `make doctor` verifies binaries, symlinks, and
submodule state.

**New zsh plugin** — add a submodule under
`tiers/terminal/dotfiles/.config/omz-custom/plugins/` and list it in
`plugins=(...)` in `tiers/terminal/dotfiles/.zshrc`. (`ZSH_CUSTOM` points to
`~/.config/omz-custom` so the shell tier owns `~/.oh-my-zsh` and the terminal
tier owns the plugins — tiers never stow into the same `$HOME` subtree.)

## Logs & state

- Install log: `~/.local/state/edw-kit/install.log`
- Recorded profile (drives `make sync`): `~/.local/state/edw-kit/profile`
