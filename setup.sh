#!/bin/bash

# OpenClaw Setup Script for Linux/macOS
# This script installs OpenClaw, configures Telegram and WhatsApp, and starts the bot.

echo "🦞 Welcome to OpenClaw Setup!"
echo "This script will help you set up your personal AI assistant."

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js is not installed."
    echo "Please install Node.js (version 22 or higher) from https://nodejs.org/"
    exit 1
fi

echo "📦 Installing OpenClaw..."
npm install -g openclaw@latest

# Create configuration directory
CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
mkdir -p "$CONFIG_DIR"

echo ""
echo "🤖 Telegram Configuration"
echo "Please enter your Telegram Bot Token (from @BotFather):"
read -r TELEGRAM_TOKEN

echo "Please enter your Telegram User ID (from @userinfobot):"
read -r TELEGRAM_USER_ID

# Create configuration file
cat > "$CONFIG_FILE" <<EOF
{
  "channels": {
    "telegram": {
      "botToken": "$TELEGRAM_TOKEN",
      "allowFrom": [
        "$TELEGRAM_USER_ID"
      ],
      "enabled": true
    },
    "whatsapp": {
      "dmPolicy": "open",
      "allowFrom": [
        "*"
      ],
      "enabled": true
    }
  },
  "agents": {
    "defaults": {
      "model": "anthropic/claude-3-5-sonnet-20240620",
      "thinking": "high"
    }
  }
}
EOF

echo "✅ Configuration saved to $CONFIG_FILE"
echo "   - Telegram: Private (User ID: $TELEGRAM_USER_ID)"
echo "   - WhatsApp: Public (Customers can message freely)"

echo ""
echo "📱 WhatsApp Pairing"
echo "The script will now run 'openclaw channels login'."
echo "Please scan the QR code with your WhatsApp Business app (Linked Devices)."
echo "Press Enter to continue..."
read -r

# Run WhatsApp pairing
openclaw channels login

echo ""
echo "🚀 Starting OpenClaw Gateway..."
echo "Your bot is now running!"
openclaw gateway --port 18789 --verbose
