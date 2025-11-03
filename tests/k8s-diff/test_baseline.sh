#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

KUBECONFIG_PATH="${KUBECONFIG_PATH:-${KUBECONFIG:-}}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "ERROR: kubectl is required for baseline diff tests." >&2
  exit 1
fi

if [ -z "${KUBECONFIG_PATH}" ]; then
  echo "ERROR: set KUBECONFIG or KUBECONFIG_PATH to a kubeconfig with access to the cluster." >&2
  exit 1
fi

if [ ! -f "${KUBECONFIG_PATH}" ]; then
  echo "ERROR: kubeconfig not found at ${KUBECONFIG_PATH}" >&2
  exit 1
fi

export KUBECONFIG="${KUBECONFIG_PATH}"

MANIFEST_ROOT="${REPO_ROOT}/cluster/base"

if [ ! -d "${MANIFEST_ROOT}" ]; then
  echo "ERROR: expected manifests under ${MANIFEST_ROOT}. Run bootstrap tasks first." >&2
  exit 1
fi

echo "Running kubectl diff for baseline system manifests..."
kubectl diff -f "${MANIFEST_ROOT}/system" || {
  status=$?
  if [ "${status}" -eq 1 ]; then
    echo "kubectl diff reported changes. Review output above." >&2
  fi
  exit "${status}"
}

echo "Baseline manifest diff completed successfully."
