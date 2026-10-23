#!/bin/bash
# Build and install a patched Emacs from source.
# Clones (or updates) the repo, applies local pgtk patches, builds, and installs.
#
# Usage:
#   ~/.dot/emacs/build-emacs.sh            # fresh clone + build
#   ~/.dot/emacs/build-emacs.sh --rebuild  # pull + reapply patches + rebuild
#
set -e

EMACS_REPO="https://github.com/emacs-mirror/emacs.git"
EMACS_BRANCH="emacs-30"
EMACS_SRC="${EMACS_SRC:-$HOME/dev/emacs}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOBS="$(nproc)"

REBUILD=false
for arg in "$@"; do
  case $arg in
    --rebuild) REBUILD=true ;;
    -h|--help)
      echo "Usage: $0 [--rebuild]"
      echo "  (no flag)  Clone, patch, build, install from scratch."
      echo "  --rebuild  Pull latest upstream, reapply patches, rebuild."
      exit 0 ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

deps=(
  git autoconf make gcc libgccjit-dev
  libgtk-3-dev libglib2.0-dev libcairo2-dev libpango1.0-dev
  libgdk-pixbuf-2.0-dev libharfbuzz-dev
  libsqlite3-dev
  libgnutls28-dev libxml2-dev libncurses-dev
  libjansson-dev libtree-sitter-dev
  pkg-config texinfo
)

echo "==> Checking build dependencies..."
missing=()
for pkg in "${deps[@]}"; do
  dpkg -s "$pkg" &>/dev/null || missing+=("$pkg")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Installing missing packages: ${missing[*]}"
  sudo apt-get install -y "${missing[@]}"
fi

if [ "$REBUILD" = false ]; then
  if [ -d "$EMACS_SRC" ]; then
    echo "==> $EMACS_SRC already exists — use --rebuild to update it."
    exit 1
  fi
  echo "==> Cloning Emacs ($EMACS_BRANCH) into $EMACS_SRC..."
  git clone --depth=1 --branch "$EMACS_BRANCH" "$EMACS_REPO" "$EMACS_SRC"
else
  echo "==> Pulling latest upstream..."
  git -C "$EMACS_SRC" fetch origin "$EMACS_BRANCH"
  git -C "$EMACS_SRC" checkout "$EMACS_BRANCH"
  # Reset to upstream, discarding any previously applied patches
  git -C "$EMACS_SRC" reset --hard "origin/$EMACS_BRANCH"
fi

echo "==> Applying patches..."
"$SCRIPT_DIR/apply-patches.sh"

echo "==> Configuring..."
cd "$EMACS_SRC"
./autogen.sh
./configure \
  --with-pgtk \
  --with-native-compilation=aot \
  --with-sqlite3 \
  --with-tree-sitter \
  --with-json \
  --with-gnutls \
  --with-xml2 \
  --without-x

echo "==> Building with $JOBS jobs..."
make -j"$JOBS"

echo "==> Installing..."
sudo make install

echo ""
echo "Done! Restart Emacs."
echo "Verify: emacs --batch --eval '(message \"%s %s\" (sqlite-available-p) (native-comp-available-p))'"
