#!/usr/bin/env bash
set -euo pipefail

SESSION="${HERMES_TMUX_SESSION:-hermes-gateway}"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "== Hermes 命令 =="
if command -v hermes >/dev/null 2>&1; then
  hermes --version 2>/dev/null || true
else
  echo "未找到 hermes。请先执行：cd ~/Hermes && bash scripts/install_mac.sh"
fi

echo
echo "== Hermes 状态 =="
if command -v hermes >/dev/null 2>&1; then
  hermes status --all || true
  hermes gateway status || true
fi

echo
echo "== tmux 会话 =="
if command -v tmux >/dev/null 2>&1; then
  if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "tmux 会话正在运行：$SESSION"
    tmux capture-pane -t "$SESSION" -p | tail -80
  else
    echo "tmux 会话未运行：$SESSION"
  fi
else
  echo "未找到 tmux"
fi

echo
echo "== 关键日志 =="
for log_file in \
  "$HERMES_HOME/logs/gateway.log" \
  "$HERMES_HOME/logs/tmux-gateway.log" \
  "$HERMES_HOME/logs/launchd-gateway.out.log" \
  "$HERMES_HOME/logs/launchd-gateway.err.log"; do
  if [[ -f "$log_file" ]]; then
    echo "-- $log_file"
    grep -i -E 'dingtalk|connected via stream|unauthorized|failed|error|exception|traceback' "$log_file" | tail -80 || true
  fi
done

if [[ ! -d "$HERMES_HOME/logs" ]]; then
  echo "日志目录不存在：$HERMES_HOME/logs"
fi
