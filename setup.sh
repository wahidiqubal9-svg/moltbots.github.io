#!/bin/bash
set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for node and npm
if ! command_exists node || ! command_exists npm; then
  echo "Error: Node.js and npm are required. Please install them first."
  exit 1
fi

echo "Welcome to OpenClaw Setup Wizard!"
echo "This script will help you configure OpenClaw with Telegram and DeepSeek."
echo ""

# Prompt for credentials
read -p "Enter your Telegram Bot Token: " TELEGRAM_BOT_TOKEN
read -p "Enter your Telegram User ID: " TELEGRAM_USER_ID
read -p "Enter your DeepSeek API Key: " DEEPSEEK_API_KEY

echo ""
echo "Installing OpenClaw..."
if npm install -g openclaw@latest; then
  echo "OpenClaw installed successfully."
else
  echo "Installation failed (likely permission error). Trying with sudo..."
  sudo npm install -g openclaw@latest
fi

echo ""
echo "Configuring OpenClaw..."
mkdir -p ~/.openclaw

# Backup existing config if it exists
if [ -f ~/.openclaw/openclaw.json ]; then
  echo "Backing up existing configuration to ~/.openclaw/openclaw.json.bak"
  cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
fi

# Create configuration file
cat <<EOF > ~/.openclaw/openclaw.json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$TELEGRAM_BOT_TOKEN",
      "dmPolicy": "allowlist",
      "allowFrom": ["tg:$TELEGRAM_USER_ID"]
    }
  },
  "models": {
    "providers": {
      "deepseek": {
        "baseUrl": "https://api.deepseek.com",
        "apiKey": "$DEEPSEEK_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "deepseek-chat",
            "name": "DeepSeek Chat",
            "contextWindow": 32000,
            "maxTokens": 4096
          },
          {
            "id": "deepseek-coder",
            "name": "DeepSeek Coder",
            "contextWindow": 32000,
            "maxTokens": 4096
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "deepseek/deepseek-chat"
      },
      "models": {
        "deepseek/deepseek-chat": { "alias": "DeepSeek" }
      }
    }
  }
}
EOF

echo "Configuration saved to ~/.openclaw/openclaw.json"

echo ""
echo "Verifying installation..."
openclaw --version

if command_exists openclaw; then
  echo "Running openclaw doctor..."
  openclaw doctor || echo "Warning: openclaw doctor reported issues."
else
  echo "Error: openclaw command not found."
fi

echo ""
echo "Setup complete!"
echo "To start the bot, run: openclaw gateway"
