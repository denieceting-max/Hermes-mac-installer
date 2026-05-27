#!/usr/bin/env bash
set -euo pipefail

LABEL="com.hermes.dashboard"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl stop "$LABEL" >/dev/null 2>&1 || true

if [[ -f "$PLIST" ]]; then
  launchctl unload "$PLIST" >/dev/null 2>&1 || true
  rm -f "$PLIST"
  echo "已卸载 Hermes Dashboard 开机自启动：$LABEL"
else
  echo "未找到开机自启动配置：$PLIST"
fi

launchctl list | grep "$LABEL" || true
