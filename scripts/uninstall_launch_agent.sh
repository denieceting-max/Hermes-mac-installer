#!/usr/bin/env bash
set -euo pipefail

LABEL="com.hermes.gateway"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ -f "$PLIST" ]]; then
  launchctl stop "$LABEL" >/dev/null 2>&1 || true
  launchctl unload "$PLIST" >/dev/null 2>&1 || true
  rm -f "$PLIST"
  echo "已卸载开机自启动：$LABEL"
else
  echo "未找到开机自启动配置：$PLIST"
fi

launchctl list | grep "$LABEL" || true
