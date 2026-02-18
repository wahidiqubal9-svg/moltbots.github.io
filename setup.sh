#!/bin/bash
set -e

# Ensure Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js (v22+) first."
    exit 1
fi

# Install OpenClaw if not present
if ! command -v openclaw &> /dev/null; then
    echo "Installing OpenClaw..."
    npm install -g openclaw@latest
else
    echo "OpenClaw is already installed."
fi

# Ask for configuration
echo "----------------------------------------------------"
echo "Configuring OpenClaw Virtual Assistant"
echo "----------------------------------------------------"

read -p "Enter your Telegram Bot Token: " TG_TOKEN
read -p "Enter your Telegram Admin User ID (numbers): " TG_ADMIN
read -p "Enter your AI Provider API Key: " API_KEY

echo ""
echo "Select AI Provider:"
echo "1) Anthropic (Claude 3.5 Sonnet) - Recommended"
echo "2) OpenAI (GPT-4o)"
echo "3) DeepSeek (DeepSeek Chat)"
read -p "Choice (1/2/3): " PROVIDER_CHOICE

# Export variables for the Node.js script to use safely
export TG_TOKEN
export TG_ADMIN
export API_KEY
export PROVIDER_CHOICE

# Generate JSON using Node.js
node <<EOF
const fs = require('fs');
const os = require('os');
const path = require('path');

const tgToken = process.env.TG_TOKEN;
const tgAdmin = process.env.TG_ADMIN;
const provider = process.env.PROVIDER_CHOICE;
const apiKey = process.env.API_KEY;

const template = {
  agent: { model: "" },
  channels: {
    telegram: {
      enabled: true,
      botToken: tgToken,
      allowFrom: [tgAdmin]
    },
    whatsapp: {
      enabled: true,
      allowFrom: ["*"] // Public access for WhatsApp Business consumers
    }
  },
  dmPolicy: "open", // Allow public access (globally open, restricted by allowFrom per channel where needed)
  models: { providers: [] }
};

if (provider === "3") { // DeepSeek
  template.models.providers.push({
    id: "deepseek",
    api: "openai-completions",
    baseUrl: "https://api.deepseek.com",
    apiKey: apiKey,
    models: ["deepseek-chat"]
  });
  template.agent.model = "deepseek/deepseek-chat";
} else if (provider === "2") { // OpenAI
  template.agent.model = "openai/gpt-4o";
  // OpenAI key is typically handled via env var
} else { // Anthropic (Default)
  template.agent.model = "anthropic/claude-3-5-sonnet-20240620";
}

const configDir = path.join(os.homedir(), '.openclaw');
if (!fs.existsSync(configDir)) fs.mkdirSync(configDir, { recursive: true });

const configPath = path.join(configDir, 'openclaw.json');
fs.writeFileSync(configPath, JSON.stringify(template, null, 2));
console.log("Configuration saved to " + configPath);
EOF

# Export API Key for standard providers
if [ "$PROVIDER_CHOICE" == "1" ]; then
    export ANTHROPIC_API_KEY="$API_KEY"
    echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> ~/.bashrc 2>/dev/null || true
    echo "Set ANTHROPIC_API_KEY environment variable."
elif [ "$PROVIDER_CHOICE" == "2" ]; then
    export OPENAI_API_KEY="$API_KEY"
    echo "export OPENAI_API_KEY=\"$API_KEY\"" >> ~/.bashrc 2>/dev/null || true
    echo "Set OPENAI_API_KEY environment variable."
fi

echo ""
echo "----------------------------------------------------"
echo "Setup complete!"
echo "----------------------------------------------------"
echo "Next steps:"
echo "1. Run 'openclaw channels login' to scan the QR code for WhatsApp."
echo "2. Run 'openclaw gateway' to start the bot."
echo "----------------------------------------------------"
