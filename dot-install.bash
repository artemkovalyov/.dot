#!/bin/bash

set -e  # Exit on any error

echo "Starting setup process for bash-it and dotfiles..."

# Install bash-it
if [ -d ~/.bash_it ]; then
  echo "bash-it already installed. Skipping installation."
else
  echo "Installing bash-it..."
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh --silent
  echo "bash-it installation completed."
fi

# Clone dotfiles repository
# if [ -d ~/.dot ]; then
#   echo "Dotfiles repository already exists. Updating..."
#   cd ~/.dot
#   git pull
#   echo "Dotfiles repository updated."
# else
#   echo "Cloning dotfiles repository..."
#   git clone https://github.com/artemkovalyov/.dot.git ~/.dot
#   echo "Dotfiles repository cloned."
# fi

# Create symlink for .bashrc
BASHRC_SOURCE=~/.dot/.bashrc
BASHRC_TARGET=~/.bashrc

if [ -L "$BASHRC_TARGET" ]; then
  echo "Symlink for .bashrc already exists."
  echo "Current target: $(readlink -f "$BASHRC_TARGET")"
else
  # Check if .bashrc exists but is not a symlink
  if [ -f "$BASHRC_TARGET" ]; then
    echo "Existing .bashrc found. Creating backup at ~/.bashrc.backup"
    mv "$BASHRC_TARGET" "${BASHRC_TARGET}.backup"
  fi

  # Create the symlink
  ln -s "$BASHRC_SOURCE" "$BASHRC_TARGET"
  echo "Created symlink: $BASHRC_TARGET -> $BASHRC_SOURCE"
fi

echo "Setup completed successfully!"
echo "To apply changes, please restart your terminal or run: source ~/.bashrc"
