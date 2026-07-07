#!/bin/bash
set -e

echo "=== Kali AI Assistant Installer ==="

# Install dependencies
sudo apt update && sudo apt install -y curl xterm git

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama
ollama serve >/dev/null 2>&1 &

# Custom Model
cat > KaliHelper.Modelfile << 'EOF'
FROM llama3.2:3b

SYSTEM """
You are KaliHelper — expert Kali Linux penetration testing assistant.
Specialized in recon, scanning, exploitation, scripting and red team ops.
Be technical and direct. Always include legal disclaimer when needed.
"""

PARAMETER temperature 0.65
PARAMETER num_ctx 12288
EOF

ollama rm kali-helper 2>/dev/null || true
ollama create kali-helper -f KaliHelper.Modelfile

# Core tools
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
xterm -geometry 95x35+120+80 -title "KaliHelper AI" -e bash -c 'exec kali-chat'
EOF

sudo tee /usr/local/bin/kali-legend > /dev/null << 'EOF'
#!/bin/bash
cat > /tmp/kali-legend.txt << 'LEGEND'
╔══════════════════════════════════════╗
║     🔥 KaliHelper Quick Commands     ║
╠══════════════════════════════════════╣
║  k     → Quick question              ║
║  kc    → Persistent chat             ║
║  ka    → Aider Coding Agent          ║
║  kaf   → Floating AI Terminal        ║
║  legend→ Show this window            ║
╚══════════════════════════════════════╝
LEGEND
xterm -geometry 48x20+30+100 -title "Kali AI Legend" -bg "#1e1e1e" -fg "#00ff9f" -hold -e cat /tmp/kali-legend.txt
EOF

sudo chmod +x /usr/local/bin/kali-*

# Install Aider
curl -LsSf https://aider.chat/install.sh | sh

# Aliases
if [[ -f ~/.zshrc ]]; then
    cat >> ~/.zshrc << ALIASES
alias k="ollama run kali-helper"
alias kc="kali-chat"
alias ka="kali-aider"
alias kaf="kali-ai-float"
alias legend="kali-legend"
ALIASES
    source ~/.zshrc
else
    cat >> ~/.bashrc << ALIASES
alias k="ollama run kali-helper"
alias kc="kali-chat"
alias ka="kali-aider"
alias kaf="kali-ai-float"
alias legend="kali-legend"
ALIASES
    source ~/.bashrc
fi

echo "✅ Installation Complete!"
echo "Run 'legend &' for the floating cheatsheet."
