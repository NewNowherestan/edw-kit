#!/usr/bin/env bash
set -euo pipefail

SECRETS_ROOT="${HOME}/.config/edw-kit/secrets"
SECRETS_ENV_FILE="${SECRETS_ROOT}/.env"
SECRETS_EXAMPLE_FILE="${SECRETS_ROOT}/.env.example"
SECRETS_NOTES_FILE="${SECRETS_ROOT}/README.local.md"

write_if_missing() {
  local path="$1"
  local content="$2"
  if [[ -e "${path}" ]]; then
    echo "SKIP: exists ${path}"
    return
  fi
  printf '%s\n' "${content}" >"${path}"
  chmod 600 "${path}" 2>/dev/null || true
  echo "CREATED: ${path}"
}

main() {
  mkdir -p "${SECRETS_ROOT}"
  chmod 700 "${SECRETS_ROOT}" 2>/dev/null || true

  write_if_missing "${SECRETS_EXAMPLE_FILE}" \
"# Copy to .env and fill with real values specific to your local setup.
# Never commit this file.

SERVICE_TOKEN=
SERVICE_API_KEY=
"

  write_if_missing "${SECRETS_ENV_FILE}" \
"# Local machine secrets for edw-kit bootstrap helpers.
# Keep this file out of git.
"

  write_if_missing "${SECRETS_NOTES_FILE}" \
"# Local secrets notes

- Secret files live only on this machine.
- Recommended loading method: \`set -a; source ~/.config/edw-kit/secrets/.env; set +a\`
- Optional toolchain: 1Password CLI (\`op\`) or age/sops for encrypted sync.
"

  echo "Done. Local secrets scaffold is ready in ${SECRETS_ROOT}"
}

main "$@"
