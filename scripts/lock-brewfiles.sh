#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

brew bundle lock --file="${ROOT_DIR}/brew/Brewfile.tier1"
brew bundle lock --file="${ROOT_DIR}/brew/Brewfile.tier2"
brew bundle lock --file="${ROOT_DIR}/brew/Brewfile.tier3"
