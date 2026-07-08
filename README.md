#!/bin/bash
# Kali AI Helper - Easy One-Shot Installer (Core Version)
# Run this after extracting the ZIP

set -e

echo "=========================================="
echo "   Kali AI Helper v3.0 - Core Installer"
echo "=========================================="

read -p "Continue with installation? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo "[1/6] Installing core dependencies..."
sudo apt update && sudo apt install -y \
    curl git xterm alacritty python3-pip jq

echo "[2/6] Installing Aider..."
curl -LsSf https://aider.chat/install.sh | sh

echo "[3/6] Installing Open WebUI..."
pip3 install open-webui --break-system-packages || true

echo "[4/6] Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
ollama serve >/dev/null 2>&1 &

echo "[5/6] Creating KaliHelper AI model..."
cat > /tmp/KaliHelper.Modelfile << 'EOF'
FROM llama3.2:3b

SYSTEM """
You are KaliHelper — expert Kali Linux penetration testing assistant.
Specialized in recon, scanning, exploitation, scripting and red team ops.
Be technical, direct, and helpful. Always include legal disclaimer when needed.
"""

PARAMETER temperature 0.65
PARAMETER num_ctx 12288
EOF

ollama rm kali-helper 2>/dev/null || true
ollama create kali-helper -f /tmp/KaliHelper.Modelfile

echo "[6/6] Installing commands..."

sudo tee /usr/local/bin/kali-chat > /dev/null << 'EOF'
#!/bin/bash
echo "=== KaliHelper Persistent Session ==="
ollama run kali-helper --keepalive 1h "$@"
EOF

sudo tee /usr/local/bin/kali-aider > /dev/null << 'EOF'
#!/bin/bash
aider --model ollama/kali-helper "$@"
EOF

sudo tee /usr/local/bin/kali-ai-float > /dev/null << 'EOF'
#!/bin/bash
if command -v alacritty >/dev/null; then
    alacritty -t "KaliHelper AI" --dimensions 100 38 -e bash -c 'exec kali-chat' &
else
    xterm -geometry 100x38+100+80 -title "KaliHelper AI" -e bash -c 'exec kali-chat' &
fi
EOF

sudo tee /usr/local/bin/kali-legend > /dev/null << 'EOF'
#!/bin/bash
cat > /tmp/kali-legend.txt << 'LEGEND'
╔══════════════════════════════════════╗
║     🔥 KaliHelper Quick Commands     ║
╠══════════════════════════════════════╣
║  k      → Quick question             ║
║  kc     → Persistent chat            ║
║  ka     → Aider Coding Agent         ║
║  kaf    → Floating AI Terminal       ║
║  webui  → Open WebUI (browser)       ║
║  legend → Show this window           ║
╚══════════════════════════════════════╝
LEGEND
xterm -geometry 52x22+30+80 -title "Kali AI Legend" -bg "#1e1e1e" -fg "#00ff9f" -hold -e cat /tmp/kali-legend.txt
EOF

sudo tee /usr/local/bin/start-webui.sh > /dev/null << 'EOF'
#!/bin/bash
echo "🌐 Starting Open WebUI at http://localhost:8080"
open-webui serve
EOF

sudo tee /usr/local/bin/kali-update > /dev/null << 'EOF'
#!/bin/bash
echo "🔄 Updating Kali AI Helper..."
ollama pull llama3.2:3b
curl -LsSf https://aider.chat/install.sh | sh
echo "✅ Update complete!"
EOF

sudo chmod +x /usr/local/bin/kali-* /usr/local/bin/start-webui.sh

cat >> ~/.bashrc << ALIASES
alias k="ollama run kali-helper"
alias kc="kali-chat"
alias ka="kali-aider"
alias kaf="kali-ai-float"
alias legend="kali-legend"
alias webui="start-webui.sh"
alias update="kali-update"
ALIASES

if [[ -f ~/.zshrc ]]; then
    cat >> ~/.zshrc << ALIASES
alias k="ollama run kali-helper"
alias kc="kali-chat"
alias ka="kali-aider"
alias kaf="kali-ai-float"
alias legend="kali-legend"
alias webui="start-webui.sh"
alias update="kali-update"
ALIASES
fi

echo ""
echo "✅ Installation Complete!"
echo ""
echo "Run this command now to see the floating legend:"
echo "   legend &"
echo ""
echo "Voice mode is available as a separate add-on."
