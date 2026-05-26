#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SHELL_PROFILE="$HOME/.zprofile"

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
err() { printf '\033[1;31m[ERR ]\033[0m %s\n' "$*" >&2; }

append_once() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
  fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  err "此脚本只用于 macOS。当前系统：$(uname -s)"
  exit 1
fi

info "开始安装 Hermes 到 Mac"

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Apple Command Line Tools 未安装。请先执行：xcode-select --install"
  warn "安装完成后重新运行：cd ~/Hermes && bash scripts/install_mac.sh"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  info "未检测到 Homebrew，开始安装 Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  info "已检测到 Homebrew：$(brew --version | head -1)"
fi

append_once 'export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"' "$SHELL_PROFILE"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

info "安装基础依赖：git curl python@3.11 pipx tmux"
brew install git curl python@3.11 pipx tmux

if ! python3 -m pipx --version >/dev/null 2>&1; then
  info "配置 pipx"
  python3 -m pip install --user --upgrade pipx
fi

python3 -m pipx ensurepath >/dev/null 2>&1 || true
export PATH="$HOME/.local/bin:$PATH"

if ! command -v hermes >/dev/null 2>&1; then
  info "安装 Hermes Agent"
  curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
else
  info "已检测到 Hermes：$(hermes --version 2>/dev/null | head -1 || true)"
fi

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
mkdir -p "$HERMES_HOME/logs"

if [[ ! -f "$HERMES_HOME/.env" ]]; then
  cp "$ROOT_DIR/config/.env.example" "$HERMES_HOME/.env"
  chmod 600 "$HERMES_HOME/.env"
  info "已创建 $HERMES_HOME/.env，请填写 API Key 和钉钉 Client Secret"
else
  warn "$HERMES_HOME/.env 已存在，未覆盖"
fi

if [[ ! -f "$HERMES_HOME/config.yaml" ]]; then
  cp "$ROOT_DIR/config/config.example.yaml" "$HERMES_HOME/config.yaml"
  info "已创建 $HERMES_HOME/config.yaml"
else
  warn "$HERMES_HOME/config.yaml 已存在，未覆盖"
fi

chmod +x "$ROOT_DIR"/scripts/*.sh

if command -v hermes >/dev/null 2>&1; then
  info "运行 hermes doctor 检查"
  hermes doctor || true
else
  warn "安装后仍未找到 hermes 命令。请关闭终端重新打开，或执行：export PATH=\"\$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:\$PATH\""
fi

cat <<'NEXT'

安装脚本执行完成。

下一步：
1. nano ~/.hermes/.env
2. 填写模型 API Key、DINGTALK_CLIENT_ID、DINGTALK_CLIENT_SECRET、DINGTALK_ALLOWED_USERS
3. hermes setup
4. hermes status --all
5. hermes gateway run

前台测试成功后，长期后台运行：
cd ~/Hermes
bash scripts/start_gateway_tmux.sh

检查状态：
bash scripts/check_gateway.sh

NEXT
