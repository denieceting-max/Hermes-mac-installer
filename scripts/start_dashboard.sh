#!/usr/bin/env bash
set -euo pipefail

HOST="${HERMES_DASHBOARD_HOST:-127.0.0.1}"
PORT="${HERMES_DASHBOARD_PORT:-9119}"
LOG_DIR="$HOME/.hermes/logs"
LOG_FILE="$LOG_DIR/dashboard.log"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
mkdir -p "$LOG_DIR"

if ! command -v hermes >/dev/null 2>&1; then
  echo "未找到 hermes。请先执行：cd ~/Hermes && bash scripts/install_mac.sh"
  exit 1
fi

if pgrep -f "hermes dashboard" >/dev/null 2>&1; then
  echo "Hermes Dashboard 已经在运行。"
else
  nohup hermes dashboard --host "$HOST" --port "$PORT" --tui --no-open > "$LOG_FILE" 2>&1 &
  echo "已启动 Hermes Dashboard，PID: $!"
  sleep 5
fi

echo "访问地址：http://$HOST:$PORT"
echo "日志文件：$LOG_FILE"
hermes dashboard --status || true
