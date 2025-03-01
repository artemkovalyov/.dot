#!/bin/bash

# Define file paths
ARTY_MODS_SRC="./symbols/art-mods"
ARTY_MODS_DEST="/usr/share/X11/xkb/symbols/art-mods"
EVDEV_LST_SRC="./rules/evdev.lst"
EVDEV_LST_DEST="/usr/share/X11/xkb/rules/evdev.lst"
EVDEV_XML_SRC="./rules/evdev.xml"
EVDEV_XML_DEST="/usr/share/X11/xkb/rules/evdev.xml"
EVDEV_SRC="./rules/evdev"
EVDEV_DEST="/usr/share/X11/xkb/rules/evdev"


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
      sudo cp "$src" "$dest"
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
copy_if_exists "$EVDEV_SRC" "$EVDEV_DEST"


# Reload XKB configuration
setxkbmap -option arty-mods

echo "XKB configuration reloaded"
