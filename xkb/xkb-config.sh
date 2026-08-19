#!/bin/bash
set -e

SRC="$HOME/.dot/xkb"
XKB_DEST="$HOME/.config/xkb"
FORCE=false

usage() {
  echo "Usage: $0 [-f]"
  echo "  Install XKB and KDE keyboard config for Wayland."
  echo "  -f  Overwrite existing files"
  exit 0
}

for arg in "$@"; do
  case $arg in
    -f|--force) FORCE=true ;;
    -h|--help)  usage ;;
    *) echo "Unknown option: $arg"; usage ;;
  esac
done

install_file() {
  local src=$1 dest=$2
  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    echo "Skipping $dest (use -f to overwrite)"
    return
  fi
  cp "$src" "$dest"
  echo "Installed $dest"
}

mkdir -p "$XKB_DEST/symbols" "$XKB_DEST/rules"

install_file "$SRC/symbols/art-mods"  "$XKB_DEST/symbols/art-mods"
install_file "$SRC/rules/evdev"       "$XKB_DEST/rules/evdev"
install_file "$SRC/rules/evdev.lst"   "$XKB_DEST/rules/evdev.lst"
install_file "$SRC/rules/evdev.xml"   "$XKB_DEST/rules/evdev.xml"
install_file "$SRC/.config/kxkbrc"   "$HOME/.config/kxkbrc"

echo "Done! Log out and back in to apply."
