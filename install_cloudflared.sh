#!/bin/bash
set -euo pipefail

# Install cloudflared (Cloudflare Tunnel client)
# Supports: Debian/Ubuntu, RHEL/CentOS/Fedora, Alpine, Arch Linux, macOS, or direct binary

ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH_SUFFIX="amd64" ;;
    aarch64) ARCH_SUFFIX="arm64" ;;
    armv7l)  ARCH_SUFFIX="armhf" ;;
    *)       ARCH_SUFFIX="amd64" ;;
esac

echo "[INFO] Installing cloudflared for $(uname -s) ($ARCH_SUFFIX)..."

if command -v cloudflared &>/dev/null; then
    CF_VER=$(cloudflared --version 2>/dev/null | head -1)
    echo "[OK] cloudflared already installed: $CF_VER"
    exit 0
fi

# Try package manager first
if command -v apt-get &>/dev/null; then
    echo "[INFO] Installing via apt..."
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" | sudo tee /etc/apt/sources.list.d/cloudflared.list
    sudo apt-get update -qq && sudo apt-get install -y -qq cloudflared
    echo "[OK] Installed via apt."
    exit 0
elif command -v dnf &>/dev/null; then
    echo "[INFO] Installing via dnf..."
    sudo dnf install -y cloudflared
    echo "[OK] Installed via dnf."
    exit 0
elif command -v apk &>/dev/null; then
    echo "[INFO] Installing via apk..."
    sudo apk add --no-cache cloudflared
    echo "[OK] Installed via apk."
    exit 0
elif command -v pacman &>/dev/null; then
    echo "[INFO] Installing via pacman..."
    sudo pacman -S --noconfirm cloudflared
    echo "[OK] Installed via pacman."
    exit 0
elif command -v brew &>/dev/null; then
    echo "[INFO] Installing via brew..."
    brew install cloudflared
    echo "[OK] Installed via brew."
    exit 0
fi

# Fallback: direct binary download
echo "[INFO] No package manager found. Downloading binary directly..."
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
    linux*)  OS_SUFFIX="linux" ;;
    darwin*) OS_SUFFIX="darwin" ;;
    *)       OS_SUFFIX="linux" ;;
esac

curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-${OS_SUFFIX}-${ARCH_SUFFIX}" -o /tmp/cloudflared
chmod +x /tmp/cloudflared

if [[ -w /usr/local/bin ]]; then
    sudo mv /tmp/cloudflared /usr/local/bin/cloudflared
else
    mkdir -p "$HOME/.local/bin"
    mv /tmp/cloudflared "$HOME/.local/bin/cloudflared"
    echo "[WARN] Installed to $HOME/.local/bin. Make sure it's in your PATH."
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "[OK] Installed cloudflared binary."
cloudflared --version
