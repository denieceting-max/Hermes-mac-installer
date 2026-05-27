#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
提示：install_launch_agent.sh 是旧脚本名。

现在默认推荐启动 Hermes Dashboard，也就是浏览器聊天页面：
  bash scripts/install_dashboard_launch_agent.sh

如果你明确要连接钉钉 gateway，再执行：
  bash scripts/install_gateway_launch_agent.sh
MSG

exit 1
