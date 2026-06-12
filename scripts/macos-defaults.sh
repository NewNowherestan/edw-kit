#!/usr/bin/env bash
# macos-defaults.sh — performance & snappiness tweaks.
# Intentionally not part of install.sh: `defaults write` changes are
# system-wide and opinionated, so apply them deliberately.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only" >&2; exit 1; }

echo "Applying macOS defaults..."

# Disable window open/close animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Speed up window resize
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable Dock launch animation
defaults write com.apple.dock launchanim -bool false

# Speed up Dock autohide
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Restart affected services
killall Dock
killall Finder

echo "Done. Some changes require logout to take effect."
