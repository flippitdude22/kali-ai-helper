#!/bin/bash
# Kali AI Helper - Core Installer (No Voice)

set -e

echo "=========================================="
echo "   Kali AI Helper - Core Installer"
echo "=========================================="

read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then exit 0; fi

sudo apt update && sudo apt install -y curl git xterm alacritty python3-pip jq

curl -LsSf https://aider.chat/install.sh | sh
pip3 install open-webui --break-system-packages || true

curl -fsSL https://ollama.com/install.sh | sh
ollama serve >/dev/null 2>&1 &

cat > /tmp/KaliHelper.Modelfile << 'EOF'
FROM llama3.2:3b
SYSTEM """
You are KaliHelper — expert Kali Linux penetration testing assistant.
Be technical and direct.
"""
PARAMETER temperature 0.65
PARAMETER num_ctx 12288
EOF

ollama rm kali-helper 2>/dev/null || true
ollama create kali-helper -f /tmp/KaliHelper.Modelfile

# Core commands (chat, aider, float, legend, webui, update)
sudo tee /usr/local/bin/kali-chat > /dev/null << 'EOF'
#!/bin/bash
echo "=== KaliHelper Persistent ==="
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
    xterm -geometry 100x38+100+80 -e bash -c 'exec kali-chat' &
fi
EOF

sudo tee /usr/local/bin/kali-legend > /dev/null << 'EOF'
#!/bin/bash
cat > /tmp/legend.txt << 'LEGEND'
╔══════════════════════════════════════╗
║     🔥 KaliHelper Commands           ║
╠══════════════════════════════════════╣
║ k     → Quick AI                     ║
║ kc    → Persistent chat              ║
║ ka    → Aider Coding                 ║
║ kaf   → Floating window              ║
║ webui → Browser UI                   ║
║ legend→ Show this                    ║
╚══════════════════════════════════════╝
LEGEND
xterm -geometry 50x20+30+80 -title "Legend" -bg "#1e1e1e" -fg "#00ff9f" -hold -e cat /tmp/legend.txt
EOF

sudo tee /usr/local/bin/start-webui.sh > /dev/null << 'EOF'
#!/bin/bash
echo "Starting Web UI at http://localhost:8080"
open-webui serve
EOF

sudo chmod +x /usr/local/bin/kali-* /usr/local/bin/start-webui.sh

# Aliases
cat >> ~/.bashrc << ALIASES
alias k="ollama run kali-helper"
alias kc="kali-chat"
alias ka="kali-aider"
alias kaf="kali-ai-float"
alias legend="kali-legend"
alias webui="start-webui.sh"
ALIASES

echo "✅ Core Installation Complete!"
echo "Run: legend &"
