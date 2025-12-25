#!/bin/bash

set -eufo pipefail

echo "🚀 Starting dotfile tool installation..."

# 1. Update APT first
sudo apt update

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
    if ! command -v "$pkg" &> /dev/null && ! command -v "${pkg%cat}" &> /dev/null && ! command -v "${pkg%-find}" &> /dev/null; then
        sudo apt install -y "$pkg"
    else
        echo "✅ $pkg is already installed."
    fi
done

# 3. Install 'bottom' (btm) via Cargo (since the apt version might be the wrong one)
if ! command -v btm &> /dev/null; then
    echo "🦀 Installing 'bottom' via Cargo..."
    cargo install bottom --locked
else
    echo "✅ bottom is already installed."
fi

# 4. Success message
echo "✨ All CLI tools are installed and ready!"

# Install Starship
if ! command -v starship &> /dev/null; then
    echo "🌌 Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    echo "✅ Starship is already installed."
fi
