#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_DIR="$ROOT_DIR/dist"
PACKAGE_NAME="Hermes-mac-installer.tar.gz"

mkdir -p "$PACKAGE_DIR"
rm -f "$PACKAGE_DIR/$PACKAGE_NAME"

cd "$ROOT_DIR"
tar \
  --exclude='.git' \
  --exclude='dist' \
  --exclude='tasks' \
  --exclude='*.tar.gz' \
  -czf "$PACKAGE_DIR/$PACKAGE_NAME" \
  README.md .gitignore config docs scripts

echo "已生成：$PACKAGE_DIR/$PACKAGE_NAME"
