#!/bin/bash

# set -e: exit on error
# set -u: exit on unset variables
# set -o pipefail: catch errors in piped commands
set -euo pipefail
IFS=$'\n\t'

echo "🚀 Starting Strict dotfile tool installation..."

# --- OS Detection ---
OS_TYPE="$(uname -s)"
IS_WSL=false
if [ "$OS_TYPE" == "Linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi

# --- 1. macOS INSTALLATION (Homebrew) ---
if [ "$OS_TYPE" == "Darwin" ]; then
  echo "🍎 Detected macOS. Using Homebrew..."

  # Fail if Homebrew isn't installed
  if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew not found. Please install it first."
    exit 1
  fi

  brew install ripgrep bat fd zoxide git-delta starship neovim \
    bottom fastfetch fortune lcat

# --- 2. LINUX / WSL INSTALLATION (APT + Cargo) ---
elif [ "$OS_TYPE" == "Linux" ]; then
  echo "🐧 Detected Linux (WSL: $IS_WSL). Using APT..."

  sudo apt update
  sudo apt install -y ripgrep bat fd-find zoxide git-delta curl xclip \
    make gcc g++ unzip fortune-mod fastfetch

  # Neovim (using PPA for latest unstable)
  if ! command -v nvim &>/dev/null; then
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update && sudo apt install -y neovim
  fi

  # Starship
  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # Rust-based tools (Fail if Cargo is missing)
  echo "🦀 Installing Rust-based tools..."
  cargo install bottom --locked
  cargo install lcat

  # WSL-Specific: win32yank for clipboard
  if [ "$IS_WSL" = true ]; then
    if [ ! -f /usr/local/bin/win32yank.exe ]; then
      echo "🪟 Installing win32yank for WSL..."
      curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
      unzip -p /tmp/win32yank.zip win32yank.exe >/tmp/win32yank.exe
      chmod +x /tmp/win32yank.exe
      sudo mv /tmp/win32yank.exe /usr/local/bin/
    fi
  fi
fi

# --- 3. Zsh Plugins (Shared) ---
ZSH_PLUGINS_DIR="${HOME}/.zsh-plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

echo "🔌 Syncing Zsh Plugins..."
# Autosuggestions
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
fi

# Syntax Highlighting
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
fi

# --- FZF Modern Installation ---
if [ ! -d "$HOME/.fzf" ]; then
  echo "🔍 Cloning FZF..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  echo "⚙️ Running FZF Installer..."
  # --all: installs completions and keybindings
  # --no-bash/--no-fish: only focuses on what you need
  ~/.fzf/install --all --no-bash --no-fish
else
  echo "✅ FZF is already installed via Git."
fi

echo "✨ All CLI tools installed. Any failure above would have stopped this script."
