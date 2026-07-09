#!/bin/bash
# Kali AI Helper - Voice Add-on Installer
# Run this only if you want voice input/output
sudo apt update && sudo apt upgrade -y 
set -e

echo "=========================================="
echo "   Kali AI Helper - Voice Add-on"
echo "=========================================="

read -p "Install Voice Mode? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo "Installing voice dependencies..."
sudo apt update && sudo apt install -y espeak piper-tts whisper-cpp

echo "Installing voice-ai command..."
sudo tee /usr/local/bin/voice-ai > /dev/null << 'EOF'
#!/bin/bash
echo "🎤 KaliHelper Voice Mode (Ctrl+C to exit)"
echo "Speak clearly after the beep..."

while true; do
    echo -e "\nListening (5 seconds)..."
    arecord -d 5 -f cd /tmp/voice_cmd.wav 2>/dev/null
    
    echo "Processing speech..."
    text=$(whisper-cpp /tmp/voice_cmd.wav 2>/dev/null | head -n 1 | sed 's/^[[:space:]]*//')
    
    if [ -z "$text" ]; then
        echo "Could not understand. Try again."
        continue
    fi
    
    echo "You said: $text"
    
    if [[ "$text" == *"exit"* || "$text" == *"stop"* ]]; then
        echo "Voice mode closed."
        break
    fi
    
    echo "Thinking..."
    response=$(ollama run kali-helper "$text" 2>/dev/null)
    echo -e "KaliHelper: $response\n"
    
    # Speak the response
    echo "$response" | espeak -v en-us -s 145 2>/dev/null
done
EOF

sudo chmod +x /usr/local/bin/voice-ai

echo "✅ Voice Add-on Installed!"
echo ""
echo "Usage: voice-ai"
echo "To stop: say 'exit' or press Ctrl+C"
