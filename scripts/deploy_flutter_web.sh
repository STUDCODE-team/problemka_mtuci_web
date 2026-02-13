#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  deploy_flutter_web.sh --host <host> --user <user> --source <local_build_dir> --target <remote_dir> --owner <user:group>
USAGE
}

HOST=""
USER=""
SOURCE=""
TARGET=""
OWNER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      HOST="$2"
      shift 2
      ;;
    --user)
      USER="$2"
      shift 2
      ;;
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

if [[ -z "$HOST" || -z "$USER" || -z "$SOURCE" || -z "$TARGET" || -z "$OWNER" ]]; then
  usage
  exit 1
fi

if [[ ! -d "$SOURCE" ]]; then
  echo "Build directory not found: $SOURCE" >&2
  exit 1
fi

REMOTE_TMP="${TARGET}.tmp"

ssh -o StrictHostKeyChecking=no "${USER}@${HOST}" "sudo mkdir -p '${REMOTE_TMP}' '${TARGET}'"

rsync -az --delete -e "ssh -o StrictHostKeyChecking=no" "${SOURCE}/" "${USER}@${HOST}:${REMOTE_TMP}/"

ssh -o StrictHostKeyChecking=no "${USER}@${HOST}" "
  sudo rsync -a --delete '${REMOTE_TMP}/' '${TARGET}/' &&
  sudo chown -R '${OWNER}' '${TARGET}' &&
  sudo find '${TARGET}' -type d -exec chmod 755 {} \\\; &&
  sudo find '${TARGET}' -type f -exec chmod 644 {} \\\; &&
  sudo rm -rf '${REMOTE_TMP}'
"
