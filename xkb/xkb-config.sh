#!/bin/bash

# Define file paths
ARTY_MODS_SRC="$HOME/.dot/xkb/symbols/art-mods"
ARTY_MODS_DEST="/usr/share/X11/xkb/symbols/art-mods"
EVDEV_LST_SRC="$HOME/.dot/xkb/rules/evdev.lst"
EVDEV_LST_DEST="/usr/share/X11/xkb/rules/evdev.lst"
EVDEV_XML_SRC="$HOME/.dot/xkb/rules/evdev.xml"
EVDEV_XML_DEST="/usr/share/X11/xkb/rules/evdev.xml"
EVDEV_SRC="$HOME/.dot/xkb/rules/evdev"
EVDEV_DEST="/usr/share/X11/xkb/rules/evdev"
KDE_KBD_SRC="$HOME/.dot/xkb/.config/kxkbrc"
KDE_KBD_DEST="$HOME/.config/kxkbrc"


# Default line to search for
SEARCH_LINE="art-mods"

# Directory to scan
RULES_DIR="/usr/share/X11/xkb/rules"
KDE_CONFIG_DIR="$HOME/.config"


# Parse arguments
COPY_FILES=false
RELOAD_XKB=false
SEARCH_LINE_IN_FILES=false
FORCE=false

# Parse arguments
if [ $# -eq 0 ]; then
  SHOW_HELP=true
fi

for arg in "$@"; do
  case $arg in
    -copy)
      COPY_FILES=true
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

# Function to display help
display_help() {
  echo "Usage: $0 [options] [search_string]"
  echo
  echo "Options:"
  echo "  -copy          Copy the specified files to their destinations"
  echo "  -reload        Reload the XKB configuration with the art-mods option"
  echo "  -search        Search for a specified line in the XKB rules directory"
  echo "  --force        Force overwrite of existing files during copy"
  echo "  -help          Display this help message"
  echo
  echo "Examples:"
  echo "  $0 -copy"
  echo "  $0 -reload"
  echo "  $0 -search \"custom-line\""
  echo "  $0 -copy --force"
}


# Display help if requested or no parameters are given
if [ "$SHOW_HELP" = true ]; then
  display_help
  exit 0
fi


# Function to copy file if it exists and destination file doesn't exist or force flag is set
copy_if_exists_root() {
  local src=$1
  local dest=$2
  if [ -f "$src" ]; then
    if [ -f "$dest" ] && [ "$FORCE" == false ]; then
      echo "Destination file $dest already exists. Use --force to overwrite."
    else
      sudo cp "$src" "$dest"
      echo "Copied $src to $dest"
    fi
  else
    echo "File $src does not exist"
  fi
}

copy_if_exists_user() {
  local src=$1
  local dest=$2
  if [ -f "$src" ]; then
    if [ -f "$dest" ] && [ "$FORCE" == false ]; then
      echo "Destination file $dest already exists. Use --force to overwrite."
    else
      sudo cp "$src" "$dest"
      echo "Copied $src to $dest"
    fi
  else
    echo "File $src does not exist"
  fi
}

# Function to search for the line in files
search_line_in_files() {
  local line=$1
  local dir=$2
  local found=false

  for file in "$dir"/*; do
    if [ -f "$file" ]; then
      if grep -q "$line" "$file"; then
        echo "Line '$line' found in $file"
        found=true
      fi
    fi
  done

  if [ "$found" = false ]; then
    echo "Line '$line' not found in any files in $dir"
  fi
}

# Copy files
if [ "$COPY_FILES" = true ]; then
copy_if_exists_root "$ARTY_MODS_SRC" "$ARTY_MODS_DEST"
copy_if_exists_root "$EVDEV_LST_SRC" "$EVDEV_LST_DEST"
copy_if_exists_root "$EVDEV_XML_SRC" "$EVDEV_XML_DEST"
copy_if_exists_root "$EVDEV_SRC" "$EVDEV_DEST"
copy_if_exists_user "$KDE_KBD_SRC" "$KDE_KBD_DEST"

fi

if [ "$RELOAD_XKB" = true ]; then
  setxkbmap -option arty-mods
  echo "XKB configuration reloaded with art-mods option"
fi

if [ "$SEARCH_LINE_IN_FILES" = true ]; then
  search_line_in_files "$SEARCH_LINE" "$RULES_DIR"
  search_line_in_files "$SEARCH_LINE" "$KDE_CONFIG_DIR"

fi

echo "We are done here!"
