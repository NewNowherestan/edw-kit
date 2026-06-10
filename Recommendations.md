# Recommendations for `edw-kit`

## What looks excessive

- Installing both `alacritty` and `iterm2` by default in tier2 may be redundant for many users.
- `cleanmymac` in a bootstrap profile can be considered optional/commercial overhead; move to opt-in if possible.
- Tier3 includes many GUI tools that can grow startup time; keep this tier very explicit and selective.

## What is lacking

- No explicit macOS defaults automation (`defaults write`, Dock/Finder tuning).
- No bootstrap checks for Xcode CLI tools and Rosetta on Apple Silicon.
- No backup/restore strategy for app settings (e.g., via `mackup`, `chezmoi`, or per-app exports).
- No first-run machine identity/profile concept (personal/work laptop presets).

## What may be outdated or risky

- Depending on fixed app choices can drift over time; review casks quarterly for deprecations or renames.
- `mas` apps are account-tied; bootstrap should gracefully skip when App Store auth is unavailable.

## Modern directions to evolve

- Add a non-interactive `bootstrap.sh` that installs Homebrew if missing, then invokes `install.sh`.
- Add `Brewfile.lock.json` workflow (`brew bundle lock --file=brew/Brewfile.terminal`, etc.) for reproducibility.
- Add optional secrets/environment bootstrap (`1Password CLI`, `chezmoi` templates, or `age` encrypted files).
- Add per-tier post-install health checks (verify binaries, permissions, and config links).
- Add a lightweight CI job that validates shell script syntax and Brewfile parseability.
- Add host-specific overlays (`dotfiles/hosts/<hostname>`) layered via stow for machine differences.
