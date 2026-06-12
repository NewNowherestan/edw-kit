# edw-kit

Profile-driven environment bootstrap for macOS (and a usable subset on Linux).
One repo, one command, and a fresh machine gets shell, terminal tooling, and
desktop apps — managed by **tier**, not by app.

## The tier model

Profiles are cumulative layers; each one includes everything below it:

| Profile       | Adds                                        | Platforms     |
|---------------|---------------------------------------------|---------------|
| `shell`       | oh-my-zsh core (pinned submodule)           | macOS, Linux  |
| `terminal`    | CLI tooling + zsh/tmux/vim/starship configs | macOS, Linux  |
| `workstation` | window manager, ghostty, karabiner, fonts   | macOS         |
| `full`        | GUI apps, App Store apps                    | macOS         |

Each tier is two things, kept side by side:

- **packages** — `brew/Brewfile.<tier>` applied with `brew bundle`
- **dotfiles** — `dotfiles/<tier>/` symlinked into `$HOME` with GNU stow

On top of any profile, `dotfiles/hosts/<hostname>/` is stowed automatically
when a directory matching the machine's hostname exists — machine-specific
overrides without forking the kit.

## Quick start

Fresh machine (installs Xcode CLT / Rosetta / Homebrew as needed, then the
default profile — `workstation` on macOS, `terminal` on Linux):

```bash
./bootstrap.sh
```

Already provisioned machine — apply or re-apply a profile:

```bash
./install.sh terminal          # or: make terminal
./install.sh workstation
./install.sh full
```

Useful flags:

```bash
./install.sh --profile workstation --dry-run    # print steps, change nothing
./install.sh --profile full --skip-brew         # dotfiles only
./install.sh --profile terminal --skip-stow     # packages only
```

Numeric aliases still work: `./install.sh 1` = terminal, `2` = workstation, `3` = full.

Everything is also reachable through `make` (run `make` alone to list targets):

```bash
make terminal     make doctor     make reload     make lock
```

## Repository layout

```
bootstrap.sh         fresh-machine entry point (prereqs + brew → install.sh)
install.sh           profile definitions + CLI; thin by design
lib/
  common.sh          logging, dry-run, run_step plumbing
  steps.sh           building blocks: brew_bundle, stow_package, mas_install
brew/
  Brewfile.terminal          CLI baseline
  Brewfile.terminal_extras   fun & situational TUIs
  Brewfile.workstation       macOS desktop layer
  Brewfile.full              GUI + App Store apps
dotfiles/
  shell/             oh-my-zsh core (submodule)
  terminal/          .zshrc, .tmux.conf, .vimrc, starship, omz custom plugins
  workstation/       ghostty, karabiner
  hosts/<hostname>/  per-machine overlay (optional)
scripts/
  doctor.sh          health check: binaries, symlinks, submodules
  reload-env.sh      reload configs in running tmux/ghostty/direnv
  macos-defaults.sh  opinionated macOS performance defaults (manual, opt-in)
  lock-brewfiles.sh  regenerate Brewfile.lock.json files
  secrets-bootstrap.sh  local (non-git) secrets scaffold
docs/cheatsheets/    vim, tmux, aliases, tools quick references
usr/                 taskwarrior data (TASKDATA via .envrc)
```

## Maintenance recipes

**Add a CLI tool** — add a `brew "name"  # why` line to the right Brewfile
tier, then `./install.sh <tier>` (idempotent, safe to re-run). Candidate
apps live as commented lines in the Brewfiles — uncomment to adopt.

**Add a dotfile** — place it under `dotfiles/<tier>/` mirroring its path
relative to `$HOME` (e.g. `dotfiles/terminal/.config/foo/bar.toml` →
`~/.config/foo/bar.toml`), then `./install.sh <tier>`.

**Machine-specific config** — create `dotfiles/hosts/$(hostname -s)/` with
the same `$HOME`-mirroring layout; it is stowed after the profile packages.

**After editing configs** — `make reload` nudges running tmux/ghostty;
zsh changes need `exec zsh`.

**Something feels off** — `make doctor` verifies binaries, symlinks, and
submodule state.

**New zsh plugin** — add a submodule under
`dotfiles/terminal/.oh-my-zsh/custom/plugins/` and list it in `plugins=(...)`
in `dotfiles/terminal/.zshrc`.

## Logs

Install runs append to `~/.local/state/edw-kit/install.log`.
