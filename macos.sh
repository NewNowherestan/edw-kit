#!/usr/bin/env bash
# macos.sh — performance & snappiness tweaks

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

# Disable Dashboard (frees memory)
defaults write com.apple.dashboard mcx-disabled -bool true

# Faster key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Apply — restart affected services
killall Dock
killall Finder

echo "Done. Some changes require logout to take effect."
