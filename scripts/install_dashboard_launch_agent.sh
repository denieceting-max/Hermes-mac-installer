#!/usr/bin/env bash
set -euo pipefail

LABEL="com.hermes.dashboard"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/.hermes/logs"
HOST="${HERMES_DASHBOARD_HOST:-127.0.0.1}"
PORT="${HERMES_DASHBOARD_PORT:-9119}"

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
    <string>export PATH="\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH"; "$HERMES_BIN" dashboard --host "$HOST" --port "$PORT" --tui --no-open</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>WorkingDirectory</key>
  <string>$HOME</string>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/dashboard-launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/dashboard-launchd.err.log</string>
</dict>
</plist>
PLIST

launchctl unload "$PLIST" >/dev/null 2>&1 || true
launchctl load "$PLIST"
launchctl start "$LABEL" || true

echo "已安装并启动 Hermes Dashboard 开机自启动：$LABEL"
echo "访问地址：http://$HOST:$PORT"
echo "配置文件：$PLIST"
echo "日志：$LOG_DIR/dashboard-launchd.out.log 和 $LOG_DIR/dashboard-launchd.err.log"
echo
launchctl list | grep "$LABEL" || true
