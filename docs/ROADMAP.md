# Roadmap / open ideas

Carried over from the original Recommendations.md; items already done
(bootstrap.sh, CI validation, host overlays, doctor health check,
macOS defaults script, secrets scaffold) have been dropped.

- **App settings backup/restore** — IDE, AlDente, Maccy etc. keep state
  outside dotfiles. Evaluate `mackup`, per-app `defaults export`, or moving
  more apps to file-based config under `dotfiles/`.
- **Machine identity presets** — host overlays cover per-machine dotfiles;
  a personal/work split for Brewfiles (e.g. `Brewfile.hosts/<name>`) is
  still open if a work laptop joins.
- **Brewfile lock workflow** — `scripts/lock-brewfiles.sh` exists, but lock
  files are not committed/enforced. Decide whether reproducibility matters
  enough to commit `*.lock.json` and check them in CI.
- **Quarterly cask review** — casks drift (renames, deprecations, e.g.
  bartender ownership change → `jordanbaird-ice` candidate). Calendar nudge
  or a CI job diffing `brew bundle list` against current cask names.
- **Secrets toolchain** — scaffold exists (`make secrets`); pick the real
  mechanism: 1Password CLI, or age/sops-encrypted files in-repo.
