#!/usr/bin/env bash
set -euo pipefail

SESSION="${HERMES_TMUX_SESSION:-hermes-gateway}"
LOG_DIR="$HOME/.hermes/logs"
LOG_FILE="$LOG_DIR/tmux-gateway.log"

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
mkdir -p "$LOG_DIR"

if ! command -v tmux >/dev/null 2>&1; then
  echo "未找到 tmux。请先执行：brew install tmux"
  exit 1
fi

if ! command -v hermes >/dev/null 2>&1; then
  echo "未找到 hermes。请先执行：cd ~/Hermes && bash scripts/install_mac.sh"
  exit 1
fi

if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "tmux 会话已存在：$SESSION"
  echo "最近输出："
  tmux capture-pane -t "$SESSION" -p | tail -80
  exit 0
fi

tmux new-session -d -s "$SESSION" "mkdir -p '$LOG_DIR'; export PATH=\"\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH\"; hermes gateway run 2>&1 | tee -a '$LOG_FILE'"

echo "已启动 tmux 会话：$SESSION"
echo "日志文件：$LOG_FILE"
sleep 3
tmux capture-pane -t "$SESSION" -p | tail -80
