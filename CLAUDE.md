# edw-kit — conventions for AI assistants

Personal environment bootstrap kit (dotfiles + Homebrew), organized by
cumulative **tiers** (`shell ⊂ terminal ⊂ workstation ⊂ full`), never by app.
See README.md for the full layout.

## Hard rules

- **bash 3.2 compatible** — bootstrap/install run on fresh macOS before
  Homebrew bash exists. No associative arrays, no `${var,,}`, no `mapfile`.
- **Tiers are self-contained** — everything a tier owns lives in
  `tiers/<name>/` (Brewfile*, dotfiles/, before.sh, after.sh, macos-only
  marker). New packages go into the lowest tier where they belong, with a
  one-line `# why` comment. Suggested-but-unadopted apps stay as commented
  Brewfile lines.
- **Dotfiles mirror `$HOME`** — `tiers/<tier>/dotfiles/path` stows to
  `~/path`. Never edit files in `~` directly; they are symlinks into this
  repo. Beware stow folding: `~/.config/tmux` etc. may be symlinks to repo
  *directories*, so deleting "local" files through them deletes repo files.
- **The tier engine is lib/steps.sh** (`apply_tier`); profiles in install.sh
  are just ordered tier lists. Host overlays (`hosts/<hostname>/`) are
  ordinary tiers applied last.
- **Tiers own disjoint `$HOME` subtrees** — stow cannot unfold a directory
  symlink owned by another tier's stow dir. This is why omz plugins live in
  `~/.config/omz-custom` (terminal tier, via `ZSH_CUSTOM`) instead of inside
  `~/.oh-my-zsh` (shell tier).
- **Idempotency** — every script must be safe to re-run (`--restow`,
  `brew bundle`, guarded writes). `make sync` re-applies the recorded
  profile (`~/.local/state/edw-kit/profile`, highest ever wins).
- **mas entries** never install via `brew bundle` (HOMEBREW_BUNDLE_MAS_SKIP
  is always set); they belong in a tier's after.sh via `mas_install`.
- `usr/taskchampion.sqlite3` is versioned intentionally (taskwarrior sync);
  its `-shm`/`-wal` siblings are ignored and must stay untracked.

## Verifying changes

- `make check` — bash -n over all scripts
- `./install.sh --profile <p> --dry-run` — prints the step plan
- `./scripts/doctor.sh` — post-install health check
