#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  deploy_flutter_web_local.sh --source <local_build_dir> --target <target_dir> --owner <user:group>
USAGE
}

SOURCE=""
TARGET=""
OWNER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE="$2"
      shift 2
      ;;
    --target)
      TARGET="$2"
      shift 2
      ;;
    --owner)
      OWNER="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$SOURCE" || -z "$TARGET" || -z "$OWNER" ]]; then
  usage
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "Build directory not found: $SOURCE" >&2
  exit 1
fi

TMP_DIR="${TARGET}.tmp"

sudo mkdir -p "${TMP_DIR}" "${TARGET}"

sudo rsync -a --delete "${SOURCE}/" "${TMP_DIR}/"
sudo rsync -a --delete "${TMP_DIR}/" "${TARGET}/"

sudo chown -R "${OWNER}" "${TARGET}"
sudo find "${TARGET}" -type d -exec chmod 755 {} \;
sudo find "${TARGET}" -type f -exec chmod 644 {} \;
sudo rm -rf "${TMP_DIR}"
