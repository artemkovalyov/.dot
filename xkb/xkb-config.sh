#!/bin/bash

# Define file paths
ARTY_MODS_SRC="$HOME/.dot/xkb/symbols/art-mods"
EVDEV_LST_SRC="$HOME/.dot/xkb/rules/evdev.lst"
EVDEV_XML_SRC="$HOME/.dot/xkb/rules/evdev.xml"
EVDEV_SRC="$HOME/.dot/xkb/rules/evdev"
KDE_KBD_SRC="$HOME/.dot/xkb/.config/kxkbrc"

# X11 destinations (system-wide, require sudo)
ARTY_MODS_X11="/usr/share/X11/xkb/symbols/art-mods"
EVDEV_LST_X11="/usr/share/X11/xkb/rules/evdev.lst"
EVDEV_XML_X11="/usr/share/X11/xkb/rules/evdev.xml"
EVDEV_X11="/usr/share/X11/xkb/rules/evdev"

# Wayland destinations (user-level, no sudo)
ARTY_MODS_WL="$HOME/.config/xkb/symbols/art-mods"
EVDEV_LST_WL="$HOME/.config/xkb/rules/evdev.lst"
EVDEV_XML_WL="$HOME/.config/xkb/rules/evdev.xml"
EVDEV_WL="$HOME/.config/xkb/rules/evdev"

KDE_KBD_DEST="$HOME/.config/kxkbrc"

# Default line to search for
SEARCH_LINE="art-mods"

# Directory to scan
RULES_DIR_X11="/usr/share/X11/xkb/rules"
RULES_DIR_WL="$HOME/.config/xkb/rules"
KDE_CONFIG_DIR="$HOME/.config"

# Parse arguments
COPY_X11=false
COPY_WAYLAND=false
RELOAD_XKB=false
SEARCH_LINE_IN_FILES=false
FORCE=false
SHOW_HELP=false

if [ $# -eq 0 ]; then
  SHOW_HELP=true
fi

for arg in "$@"; do
  case $arg in
    -copy-x11)
      COPY_X11=true
      ;;
    -copy-wayland)
      COPY_WAYLAND=true
      ;;
    -copy)
      COPY_X11=true
      COPY_WAYLAND=true
      ;;
    -reload)
      RELOAD_XKB=true
      ;;
    -search)
      SEARCH_LINE_IN_FILES=true
      ;;
    --force)
      FORCE=true
      ;;
    -help)
      SHOW_HELP=true
      ;;
    *)
      if [ "$SEARCH_LINE_IN_FILES" = true ]; then
        SEARCH_LINE="$arg"
      else
        echo "Unknown option: $arg"
        SHOW_HELP=true
      fi
      ;;
  esac
done

display_help() {
  echo "Usage: $0 [options] [search_string]"
  echo
  echo "Options:"
  echo "  -copy            Copy files for both X11 and Wayland"
  echo "  -copy-x11        Copy files to /usr/share/X11/xkb (requires sudo)"
  echo "  -copy-wayland    Copy files to ~/.config/xkb (no sudo needed)"
  echo "  -reload          Reload XKB via setxkbmap (X11 only)"
  echo "  -search          Search for a string in XKB rules directories"
  echo "  --force          Overwrite existing files"
  echo "  -help            Display this help message"
  echo
  echo "Examples:"
  echo "  $0 -copy-wayland"
  echo "  $0 -copy-x11 --force"
  echo "  $0 -copy"
  echo "  $0 -search \"art-mods\""
}

if [ "$SHOW_HELP" = true ]; then
  display_help
  exit 0
fi

copy_root() {
  local src=$1
  local dest=$2
  if [ ! -f "$src" ]; then
    echo "Source file $src does not exist"
    return
  fi
  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    echo "Destination $dest already exists. Use --force to overwrite."
  else
    sudo cp "$src" "$dest"
    echo "Copied $src to $dest"
  fi
}

copy_user() {
  local src=$1
  local dest=$2
  if [ ! -f "$src" ]; then
    echo "Source file $src does not exist"
    return
  fi
  if [ -f "$dest" ] && [ "$FORCE" = false ]; then
    echo "Destination $dest already exists. Use --force to overwrite."
  else
    cp "$src" "$dest"
    echo "Copied $src to $dest"
  fi
}

search_line_in_files() {
  local line=$1
  local dir=$2
  local found=false
  for file in "$dir"/*; do
    if [ -f "$file" ] && grep -q "$line" "$file"; then
      echo "Found '$line' in $file"
      found=true
    fi
  done
  if [ "$found" = false ]; then
    echo "'$line' not found in any files in $dir"
  fi
}

if [ "$COPY_WAYLAND" = true ]; then
  mkdir -p "$HOME/.config/xkb/symbols" "$HOME/.config/xkb/rules"
  copy_user "$ARTY_MODS_SRC" "$ARTY_MODS_WL"
  copy_user "$EVDEV_LST_SRC" "$EVDEV_LST_WL"
  copy_user "$EVDEV_XML_SRC" "$EVDEV_XML_WL"
  copy_user "$EVDEV_SRC"     "$EVDEV_WL"
  copy_user "$KDE_KBD_SRC"   "$KDE_KBD_DEST"
fi

if [ "$COPY_X11" = true ]; then
  copy_root "$ARTY_MODS_SRC" "$ARTY_MODS_X11"
  copy_root "$EVDEV_LST_SRC" "$EVDEV_LST_X11"
  copy_root "$EVDEV_XML_SRC" "$EVDEV_XML_X11"
  copy_root "$EVDEV_SRC"     "$EVDEV_X11"
  copy_user "$KDE_KBD_SRC"   "$KDE_KBD_DEST"
fi

if [ "$RELOAD_XKB" = true ]; then
  setxkbmap -option art-mods
  echo "XKB configuration reloaded with art-mods option"
fi

if [ "$SEARCH_LINE_IN_FILES" = true ]; then
  search_line_in_files "$SEARCH_LINE" "$RULES_DIR_X11"
  search_line_in_files "$SEARCH_LINE" "$RULES_DIR_WL"
  search_line_in_files "$SEARCH_LINE" "$KDE_CONFIG_DIR"
fi

echo "Done!"
