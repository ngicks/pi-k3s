#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <artifact-dir> <kubectl|helm> [args...]" >&2
  exit 1
fi

ARTIFACT_DIR="$1"
shift
mkdir -p "$ARTIFACT_DIR"

CMD="$1"
shift
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUTPUT_FILE="$ARTIFACT_DIR/${CMD}-diff-${TIMESTAMP}.log"

case "$CMD" in
  kubectl)
    kubectl diff "$@" | tee "$OUTPUT_FILE"
    ;;
  helm)
    helm diff "$@" | tee "$OUTPUT_FILE"
    ;;
  *)
    echo "Unsupported command: $CMD" >&2
    exit 2
    ;;
esac

echo "Diff output saved to $OUTPUT_FILE"
