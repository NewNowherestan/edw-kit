# edw-kit — common entry points. Run `make` to list them.
.DEFAULT_GOAL := help

.PHONY: help bootstrap sync shell terminal workstation full doctor reload lock secrets macos-defaults check

help: ## List available targets
	@awk 'BEGIN {FS = ":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

bootstrap: ## Fresh machine: prerequisites + Homebrew + default profile
	./bootstrap.sh

sync: ## Daily: re-apply this machine's recorded profile (after git pull)
	./scripts/sync.sh

shell: ## Apply the shell profile (oh-my-zsh core)
	./install.sh shell

terminal: ## Apply the terminal profile (CLI tooling + dotfiles)
	./install.sh terminal

workstation: ## Apply the workstation profile (macOS desktop layer)
	./install.sh workstation

full: ## Apply the full profile (GUI + App Store apps)
	./install.sh full

doctor: ## Verify binaries, symlinks, and submodules
	./scripts/doctor.sh

reload: ## Reload configs in running tmux/ghostty/direnv
	./scripts/reload-env.sh

lock: ## Regenerate Brewfile lock files
	./scripts/lock-brewfiles.sh

secrets: ## Scaffold local (non-git) secrets directory
	./scripts/secrets-bootstrap.sh

macos-defaults: ## Apply opinionated macOS performance defaults
	./scripts/macos-defaults.sh

check: ## Syntax-check all shell scripts (what CI runs)
	@for f in bootstrap.sh install.sh lib/*.sh scripts/*.sh tiers/*/before.sh tiers/*/after.sh; do \
		[ -f "$$f" ] || continue; \
		bash -n "$$f" && echo "✓ $$f"; \
	done
