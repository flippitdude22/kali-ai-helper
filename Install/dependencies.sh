#!/bin/bash
echo "=== Installing All Dependencies ==="

sudo apt update

sudo apt install -y \
    curl git xterm alacritty espeak piper-tts \
    python3-pip jq \
    build-essential

# Install Aider
curl -LsSf https://aider.chat/install.sh | sh

# Install Open WebUI
pip3 install open-webui --break-system-packages

echo "✅ All dependencies installed!"
