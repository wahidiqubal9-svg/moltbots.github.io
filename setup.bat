@echo off
setlocal

echo 🦞 Welcome to OpenClaw Setup!
echo This script will help you set up your personal AI assistant.

REM Check for Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Error: Node.js is not installed.
    echo Please install Node.js (version 22 or higher) from https://nodejs.org/
    exit /b 1
)

echo 📦 Installing OpenClaw...
call npm install -g openclaw@latest

REM Create configuration directory
set "CONFIG_DIR=%USERPROFILE%\.openclaw"
set "CONFIG_FILE=%CONFIG_DIR%\openclaw.json"

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

echo.
echo 🤖 Telegram Configuration
set /p TELEGRAM_TOKEN="Please enter your Telegram Bot Token (from @BotFather): "
set /p TELEGRAM_USER_ID="Please enter your Telegram User ID (from @userinfobot): "

REM Create configuration file
(
echo {
echo   "channels": {
echo     "telegram": {
echo       "botToken": "%TELEGRAM_TOKEN%",
echo       "allowFrom": [
echo         "%TELEGRAM_USER_ID%"
echo       ],
echo       "enabled": true
echo     },
echo     "whatsapp": {
echo       "dmPolicy": "open",
echo       "allowFrom": [
echo         "*"
echo       ],
echo       "enabled": true
echo     }
echo   },
echo   "agents": {
echo     "defaults": {
echo       "model": "anthropic/claude-3-5-sonnet-20240620",
echo       "thinking": "high"
echo     }
echo   }
echo }
) > "%CONFIG_FILE%"

echo ✅ Configuration saved to %CONFIG_FILE%
echo    - Telegram: Private (User ID: %TELEGRAM_USER_ID%)
echo    - WhatsApp: Public (Customers can message freely)

echo.
echo 📱 WhatsApp Pairing
echo The script will now run 'openclaw channels login'.
echo Please scan the QR code with your WhatsApp Business app (Linked Devices).
echo Press any key to continue...
pause >nul

REM Run WhatsApp pairing
call openclaw channels login

echo.
echo 🚀 Starting OpenClaw Gateway...
echo Your bot is now running!
call openclaw gateway --port 18789 --verbose
