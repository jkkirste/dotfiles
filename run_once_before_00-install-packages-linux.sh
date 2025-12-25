#!/bin/bash

set -eufo pipefail

echo "🚀 Starting dotfile tool installation..."

# 1. Update APT first
sudo apt update

echo "🔍 Detecting OS..."

# Detect OS
OS_TYPE="$(uname -s)"
IS_WSL=false
if [ "$OS_TYPE" == "Linux" ] && grep -qi microsoft /proc/version; then
  IS_WSL=true
fi

# 2. Install tools available via APT
# Note: 'bat' is often 'batcat' on Ubuntu, 'fd-find' is 'fd'
PACKAGES=(
  ripgrep
  bat
  fd-find
  zoxide
  git-delta
  fzf
  curl
)

echo "📦 Installing APT packages..."
for pkg in "${PACKAGES[@]}"; do
  if ! command -v "$pkg" &>/dev/null && ! command -v "${pkg%cat}" &>/dev/null && ! command -v "${pkg%-find}" &>/dev/null; then
    sudo apt install -y "$pkg"
  else
    echo "✅ $pkg is already installed."
  fi
done

# 3. Install 'bottom' (btm) via Cargo (since the apt version might be the wrong one)
if ! command -v btm &>/dev/null; then
  echo "🦀 Installing 'bottom' via Cargo..."
  cargo install bottom --locked
else
  echo "✅ bottom is already installed."
fi

# 4. Success message
echo "✨ All CLI tools are installed and ready!"

# Install Starship
if ! command -v starship &>/dev/null; then
  echo "🌌 Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "✅ Starship is already installed."
fi

# Install Neovim (Latest Stable)
if ! command -v nvim &>/dev/null; then
  echo "💤 Installing Neovim..."
  sudo add-apt-repository ppa:neovim-ppa/unstable -y
  sudo apt update
  sudo apt install -y neovim
else
  echo "✅ Neovim is already installed."
fi

# Install dependencies for LazyVim plugins (treesitter, telescope, etc.)
sudo apt install -y make gcc g++ unzip

if [ "$OS_TYPE" == "Darwin" ]; then
  echo "🍎 Detected macOS. Using Homebrew..."
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install ripgrep bat fd fzf zoxide git-delta starship neovim bottom

# --- 2. LINUX / WSL INSTALLATION (APT) ---
elif [ "$OS_TYPE" == "Linux" ]; then
  echo "🐧 Detected Linux (WSL: $IS_WSL). Using APT..."
  sudo apt update
  sudo apt install -y ripgrep bat fd-find fzf zoxide git-delta curl xclip

  # Starship
  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # Neovim (using PPA for latest)
  if ! command -v nvim &>/dev/null; then
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update && sudo apt install -y neovim
  fi

  # WSL-Specific: win32yank for clipboard
  if [ "$IS_WSL" = true ] && [ ! -f /usr/local/bin/win32yank.exe ]; then
    echo "🪟 Installing win32yank for WSL..."
    curl -sLo /tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
    unzip -p /tmp/win32yank.zip win32yank.exe >/tmp/win32yank.exe
    chmod +x /tmp/win32yank.exe
    sudo mv /tmp/win32yank.exe /usr/local/bin/
  fi
fi

# Install Zsh Plugins
ZSH_PLUGINS_DIR="${HOME}/.zsh-plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

# Autosuggestions
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  echo "🔍 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
fi

# Syntax Highlighting (You'll want this too!)
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  echo "🔍 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
fi
