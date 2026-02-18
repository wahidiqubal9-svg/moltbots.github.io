# How to Configure Telegram for OpenClaw

This guide explains how to get your Telegram Bot Token and User ID to complete the `openclaw.json` configuration.

## 1. Create a Bot and Get the Token
1.  Open Telegram and search for **@BotFather**.
2.  Start a chat and send the command `/newbot`.
3.  Follow the instructions to choose a name and username for your bot.
4.  BotFather will give you an **API Token** (e.g., `123456789:ABCDefGhIJKlmNoPQRstuVWxyz`).
5.  Copy this token and paste it into `config/openclaw.json` replacing `YOUR_TELEGRAM_BOT_TOKEN_HERE`.

## 2. Get Your User ID
You need to restrict the bot so only you can control it (since it's a personal assistant).
1.  Open Telegram and search for **@userinfobot** or **@myidbot**.
2.  Start a chat and send `/start`.
3.  The bot will reply with your **User ID** (a number like `123456789`).
4.  Copy this ID and paste it into `config/openclaw.json` replacing `YOUR_TELEGRAM_USER_ID`.

## 3. Apply the Configuration
Move the configured file to the OpenClaw configuration directory:

```bash
mkdir -p ~/.openclaw
cp config/openclaw.json ~/.openclaw/openclaw.json
```

Then restart OpenClaw:
```bash
openclaw restart
```

Your bot should now be active on Telegram!
