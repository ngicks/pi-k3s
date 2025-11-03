#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

PLAYBOOK="${PLAYBOOK:-automation/ansible/site.yml}"
INVENTORY="${INVENTORY:-automation/ansible/inventory/hosts.yml}"

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ERROR: ansible-playbook is not available on PATH. Activate the uv environment first." >&2
  exit 1
fi

if [ ! -f "${REPO_ROOT}/${PLAYBOOK}" ]; then
  echo "ERROR: expected playbook at ${REPO_ROOT}/${PLAYBOOK}" >&2
  exit 1
fi

if [ ! -f "${REPO_ROOT}/${INVENTORY}" ]; then
  echo "ERROR: expected inventory at ${REPO_ROOT}/${INVENTORY}" >&2
  exit 1
fi

echo "Running ansible-playbook --check for ${PLAYBOOK} with inventory ${INVENTORY}"
ansible-playbook \
  --check \
  -i "${REPO_ROOT}/${INVENTORY}" \
  "${REPO_ROOT}/${PLAYBOOK}"
