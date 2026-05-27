#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
提示：uninstall_launch_agent.sh 是旧脚本名。

取消 Hermes Dashboard 开机自启动：
  bash scripts/uninstall_dashboard_launch_agent.sh

取消钉钉 gateway 开机自启动：
  bash scripts/uninstall_gateway_launch_agent.sh
MSG

exit 1
