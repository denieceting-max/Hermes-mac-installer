#!/usr/bin/env bash
set -euo pipefail
hermes status --all || true
hermes gateway status || true
LOG="$HOME/.hermes/logs/gateway.log"
if [[ -f "$LOG" ]]; then
  grep -i -E 'dingtalk|connected via stream|unauthorized|failed|error' "$LOG" | tail -100 || true
else
  echo "日志不存在：$LOG"
fi
