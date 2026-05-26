#!/usr/bin/env bash
set -euo pipefail
SESSION="hermes-gateway"
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "tmux 会话已存在：$SESSION"
  tmux capture-pane -t "$SESSION" -p | tail -80
  exit 0
fi
tmux new-session -d -s "$SESSION" 'hermes gateway run'
echo "已启动：$SESSION"
sleep 3
tmux capture-pane -t "$SESSION" -p | tail -80
