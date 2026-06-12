# edw-kit — conventions for AI assistants

Personal environment bootstrap kit (dotfiles + Homebrew), organized by
cumulative **tiers** (`shell ⊂ terminal ⊂ workstation ⊂ full`), never by app.
See README.md for the full layout.

## Hard rules

- **bash 3.2 compatible** — bootstrap/install run on fresh macOS before
  Homebrew bash exists. No associative arrays, no `${var,,}`, no `mapfile`.
- **Tier discipline** — a new package goes into the lowest Brewfile tier
  where it belongs, with a one-line `# why` comment. Suggested-but-unadopted
  apps stay as commented lines.
- **Dotfiles mirror `$HOME`** — `dotfiles/<tier>/path` stows to `~/path`.
  Never edit files in `~` directly; they are symlinks into this repo.
- **Profiles are functions** — `profile_*` in install.sh, composed only from
  building blocks in `lib/steps.sh`. New step types belong in `lib/`.
- **Idempotency** — every script must be safe to re-run (`--restow`,
  `brew bundle`, guarded writes).
- `usr/taskchampion.sqlite3` is versioned intentionally (taskwarrior sync);
  its `-shm`/`-wal` siblings are ignored and must stay untracked.

## Verifying changes

- `make check` — bash -n over all scripts
- `./install.sh --profile <p> --dry-run` — prints the step plan
- `./scripts/doctor.sh` — post-install health check
