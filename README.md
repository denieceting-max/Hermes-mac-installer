# Hermes Mac 浏览器聊天安装包

这个仓库用于把 Hermes 部署到一台长期在线的 Mac 上，并提供一个不用打开终端的浏览器聊天入口。安装完成后，你可以直接打开 `Hermes Dashboard` 页面和 Hermes 对话。

目标仓库：

```text
https://github.com/denieceting-max/Hermes-mac-installer.git
```

## 这次要实现什么

主目标不是连接钉钉，而是：

- 在 Mac 上安装 Hermes Agent。
- 配好模型 API Key。
- 启动 Hermes Dashboard Web 页面。
- 可选设置开机自启动。
- 可选创建 `Hermes Dashboard.app` 快捷方式，以后点一下就能打开聊天页面。

钉钉 gateway 脚本仍保留在 `scripts/`，但只是可选集成，不会默认启动。

## 安全提醒

不要把真实密钥提交到 GitHub。本仓库只保存模板文件。

不要提交这些内容：

- `.env`
- `~/.hermes/.env`
- API Key、Client Secret、Token、Webhook 等真实密钥

真实密钥只在 Mac 本地填写到 `~/.hermes/.env`。

## 包内文件

```text
Hermes/
├── README.md
├── config/
│   ├── .env.example
│   └── config.example.yaml
├── docs/
│   └── MAC_QUICKSTART.md
└── scripts/
    ├── build_package.sh
    ├── check_dashboard.sh
    ├── check_gateway.sh
    ├── create_dashboard_shortcut.sh
    ├── install_dashboard_launch_agent.sh
    ├── install_mac.sh
    ├── start_dashboard.sh
    ├── start_gateway_tmux.sh
    └── uninstall_dashboard_launch_agent.sh
```

## 一、新 Mac 从 GitHub 下载

在新 Mac 打开“终端”，执行：

```bash
cd ~
git clone https://github.com/denieceting-max/Hermes-mac-installer.git Hermes
cd Hermes
bash scripts/install_mac.sh
```

如果 Mac 没有安装 Apple Command Line Tools，脚本会提示安装：

```bash
xcode-select --install
```

安装完成后重新执行：

```bash
cd ~/Hermes
bash scripts/install_mac.sh
```

## 二、填写模型 API Key

安装脚本会创建：

```bash
~/.hermes/.env
~/.hermes/config.yaml
~/.hermes/logs/
```

编辑密钥：

```bash
nano ~/.hermes/.env
```

至少填写一个模型供应商的 API Key，例如：

```env
OPENROUTER_API_KEY=你的模型APIKey
```

如果你不用钉钉，`DINGTALK_CLIENT_ID`、`DINGTALK_CLIENT_SECRET` 可以保持空白。

保存 nano：按 `Ctrl+O`，回车，再按 `Ctrl+X`。

## 三、初始化 Hermes

执行：

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
hermes setup
hermes model
hermes status --all
```

如果 `hermes setup` 已经做过，可以跳过。第一次迁移建议完整执行一遍，确认模型配置能被 Hermes 识别。

## 四、启动浏览器聊天页面

执行：

```bash
cd ~/Hermes
bash scripts/start_dashboard.sh
```

浏览器访问：

```text
http://127.0.0.1:9119
```

Dashboard 启动时带了 `--tui`，页面里会有聊天入口，可直接和 Hermes 对话。

检查状态：

```bash
bash scripts/check_dashboard.sh
```

## 五、开机自启动 Dashboard

确认 Dashboard 可以正常打开后，执行：

```bash
cd ~/Hermes
bash scripts/install_dashboard_launch_agent.sh
```

之后 Mac 登录后会自动启动 Hermes Dashboard。你只要打开浏览器访问：

```text
http://127.0.0.1:9119
```

取消开机自启动：

```bash
cd ~/Hermes
bash scripts/uninstall_dashboard_launch_agent.sh
```

## 六、创建应用快捷方式

执行：

```bash
cd ~/Hermes
bash scripts/create_dashboard_shortcut.sh
```

它会创建：

```text
~/Applications/Hermes Dashboard.app
```

以后可以在 Finder 的 Applications 或 Spotlight 搜索 `Hermes Dashboard` 打开。这个快捷方式会先尝试启动 Dashboard，然后打开浏览器页面。

## 七、Mac 不要睡眠

Hermes 需要 Mac 保持在线。建议：

- Mac 插电运行。
- 系统设置里关闭自动睡眠，或设置为长期唤醒。
- 合盖可能会睡眠，尽量开盖或接显示器长期运行。

临时保持唤醒：

```bash
caffeinate -dimsu
```

## 八、可选：钉钉 gateway

如果以后又想把 Hermes 接到钉钉，再填写 `~/.hermes/.env` 里的钉钉配置：

```env
DINGTALK_CLIENT_ID=你的钉钉应用ClientID或AppKey
DINGTALK_CLIENT_SECRET=你的钉钉应用ClientSecret或AppSecret
DINGTALK_ALLOWED_USERS=*
```

然后手动启动：

```bash
cd ~/Hermes
bash scripts/start_gateway_tmux.sh
```

注意：这一步不是 Dashboard 聊天所必需的。只想用浏览器和 Hermes 对话时，不要启动 gateway。

## 九、常见问题

### 1. Dashboard 打不开

执行：

```bash
bash ~/Hermes/scripts/check_dashboard.sh
```

查看日志：

```bash
tail -100 ~/.hermes/logs/dashboard.log
tail -100 ~/.hermes/logs/dashboard-launchd.err.log
```

### 2. hermes 命令不存在

执行：

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
hermes --version
```

如果仍不存在，重新运行安装脚本：

```bash
cd ~/Hermes
bash scripts/install_mac.sh
```

### 3. 不想再开机自启动

执行：

```bash
cd ~/Hermes
bash scripts/uninstall_dashboard_launch_agent.sh
```

## 十、重新打包

在当前仓库执行：

```bash
bash scripts/build_package.sh
```

会生成：

```text
dist/Hermes-mac-installer.tar.gz
```

压缩包不包含真实 `.env` 和 `.git` 目录。
