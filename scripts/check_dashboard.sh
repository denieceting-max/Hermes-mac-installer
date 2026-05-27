#!/usr/bin/env bash
set -euo pipefail

HOST="${HERMES_DASHBOARD_HOST:-127.0.0.1}"
PORT="${HERMES_DASHBOARD_PORT:-9119}"
LOG_FILE="$HOME/.hermes/logs/dashboard.log"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "== Hermes Dashboard 状态 =="
if command -v hermes >/dev/null 2>&1; then
  hermes dashboard --status || true
else
  echo "未找到 hermes"
fi

echo
echo "== 端口检查 =="
if command -v curl >/dev/null 2>&1; then
  if curl -fsS "http://$HOST:$PORT/" >/dev/null 2>&1; then
    echo "Dashboard 可访问：http://$HOST:$PORT"
  else
    echo "Dashboard 暂时不可访问：http://$HOST:$PORT"
  fi
else
  echo "未找到 curl"
fi

echo
echo "== 最近日志 =="
if [[ -f "$LOG_FILE" ]]; then
  tail -80 "$LOG_FILE"
else
  echo "日志不存在：$LOG_FILE"
fi
