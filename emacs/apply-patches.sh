#!/bin/bash
set -e

# Apply local Emacs patches and rebuild.
# Run from the root of the Emacs source tree:
#
#   cd ~/dev/emacs
#   ~/.dot/emacs/apply-patches.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES="$SCRIPT_DIR"

usage() {
  echo "Usage: $0 [-f]"
  echo "  Apply patches and rebuild Emacs."
  echo "  Run from the root of the Emacs source tree."
  echo "  -f  Force: reset any existing patch applications first (git am --abort + reset)"
  exit 0
}

FORCE=false
for arg in "$@"; do
  case $arg in
    -f|--force) FORCE=true ;;
    -h|--help)  usage ;;
    *) echo "Unknown option: $arg"; usage ;;
  esac
done

if [ ! -f src/pgtkterm.c ]; then
  echo "Error: run this from the root of the Emacs source tree."
  exit 1
fi

if [ "$FORCE" = true ]; then
  git am --abort 2>/dev/null || true
  git checkout src/pgtkterm.c
fi

echo "Applying patches..."
for patch in "$PATCHES"/*.patch; do
  echo "  $patch"
  git am --3way "$patch"
done

echo "Building..."
make -j"$(nproc)"

echo "Done! Restart Emacs to use the patched build."
