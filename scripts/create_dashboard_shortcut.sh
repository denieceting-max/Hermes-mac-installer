#!/usr/bin/env bash
set -euo pipefail

HOST="${HERMES_DASHBOARD_HOST:-127.0.0.1}"
PORT="${HERMES_DASHBOARD_PORT:-9119}"
APP_DIR="$HOME/Applications"
APP_PATH="$APP_DIR/Hermes Dashboard.app"
SCRIPT_PATH="$APP_PATH/Contents/MacOS/open-hermes-dashboard"

mkdir -p "$APP_PATH/Contents/MacOS"

cat > "$APP_PATH/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>Hermes Dashboard</string>
  <key>CFBundleDisplayName</key>
  <string>Hermes Dashboard</string>
  <key>CFBundleIdentifier</key>
  <string>local.hermes.dashboard</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundleExecutable</key>
  <string>open-hermes-dashboard</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
</dict>
</plist>
PLIST

cat > "$SCRIPT_PATH" <<SCRIPT
#!/usr/bin/env bash
export PATH="\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH"
if command -v hermes >/dev/null 2>&1; then
  pgrep -f "hermes dashboard" >/dev/null 2>&1 || nohup hermes dashboard --host "$HOST" --port "$PORT" --tui --no-open > "\$HOME/.hermes/logs/dashboard.log" 2>&1 &
fi
sleep 2
open "http://$HOST:$PORT"
SCRIPT

chmod +x "$SCRIPT_PATH"

echo "已创建应用快捷方式：$APP_PATH"
echo "以后可从 Finder 的 Applications 或 Spotlight 搜索 Hermes Dashboard 打开。"
