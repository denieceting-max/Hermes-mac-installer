#!/usr/bin/env bash
set -euo pipefail

LABEL="com.hermes.gateway"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/.hermes/logs"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
mkdir -p "$HOME/Library/LaunchAgents" "$LOG_DIR"

HERMES_BIN="$(command -v hermes || true)"
if [[ -z "$HERMES_BIN" ]]; then
  echo "未找到 hermes。请先执行：cd ~/Hermes && bash scripts/install_mac.sh"
  exit 1
fi

cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>export PATH="\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH"; "$HERMES_BIN" gateway run</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>$HOME</string>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/launchd-gateway.out.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/launchd-gateway.err.log</string>
</dict>
</plist>
PLIST

launchctl unload "$PLIST" >/dev/null 2>&1 || true
launchctl load "$PLIST"
launchctl start "$LABEL" || true

echo "已安装并启动 Hermes 钉钉 gateway 开机自启动：$LABEL"
echo "注意：这会连接钉钉 Stream Mode。只想用浏览器聊天时，不需要执行本脚本。"
echo "配置文件：$PLIST"
echo "日志：$LOG_DIR/launchd-gateway.out.log 和 $LOG_DIR/launchd-gateway.err.log"
echo
launchctl list | grep "$LABEL" || true
