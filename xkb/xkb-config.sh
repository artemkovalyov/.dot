#!/bin/bash

# Define file paths
ARTY_MODS_SRC="path/to/arty-mods"
ARTY_MODS_DEST="/usr/lib/X11/xkb/symbols/arty-mods"
EVDEV_LST_SRC="path/to/evdev.lst"
EVDEV_LST_DEST="/usr/share/X11/xkb/rules/evdev.lst"
EVDEV_XML_SRC="path/to/evdev.xml"
EVDEV_XML_DEST="/usr/share/X11/xkb/rules/evdev.xml"

# Parse arguments
FORCE=false
if [ "$1" == "--force" ]; then
  FORCE=true
fi

# Function to copy file if it exists and destination file doesn't exist or force flag is set
copy_if_exists() {
  local src=$1
  local dest=$2
  if [ -f "$src" ]; then
    if [ -f "$dest" ] && [ "$FORCE" == false ]; then
      echo "Destination file $dest already exists. Use --force to overwrite."
    else
      cp "$src" "$dest"
      echo "Copied $src to $dest"
    fi
  else
    echo "File $src does not exist"
  fi
}

# Copy files
copy_if_exists "$ARTY_MODS_SRC" "$ARTY_MODS_DEST"
copy_if_exists "$EVDEV_LST_SRC" "$EVDEV_LST_DEST"
copy_if_exists "$EVDEV_XML_SRC" "$EVDEV_XML_DEST"

# Reload XKB configuration
setxkbmap -layout us

echo "XKB configuration reloaded"
