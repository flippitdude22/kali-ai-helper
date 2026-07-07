#!/bin/bash
echo "Updating KaliHelper model..."

cat > KaliHelper.Modelfile << 'EOF'
FROM llama3.2:3b

SYSTEM """
You are KaliHelper — expert Kali Linux penetration testing assistant.
Specialized in recon, scanning, exploitation, scripting and red team ops.
Be technical, direct, and helpful. Always include legal disclaimer when needed.
"""

PARAMETER temperature 0.65
PARAMETER num_ctx 12288
PARAMETER top_p 0.9
EOF

ollama rm kali-helper 2>/dev/null || true
ollama create kali-helper -f KaliHelper.Modelfile

echo "✅ KaliHelper model updated successfully!"
