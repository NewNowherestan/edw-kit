#!/usr/bin/env bash
# tiers/full/after.sh — Mac App Store installs.
# `mas` entries in the Brewfile are skipped during brew bundle (they abort
# when no account is signed in); install them here with graceful checks.
set -euo pipefail

source "${EDW_ROOT}/lib/common.sh"
source "${EDW_ROOT}/lib/steps.sh"

mas_install "1Focus" "1258530160"
