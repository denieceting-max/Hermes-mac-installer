# Hermes Mac 部署安装包

这个仓库用于把当前 Windows 电脑上的 Hermes 钉钉网关迁移到一台长期在线的 Mac 上运行。新 Mac 不需要预先安装 Hermes，本包会引导安装 macOS 依赖、Hermes Agent、配置模板、后台运行脚本和可选开机自启动。

目标仓库：

```text
https://github.com/denieceting-max/Hermes-mac-installer.git
```

## 安全提醒

不要把真实密钥提交到 GitHub。本仓库只保存模板文件。

不要提交这些内容：

- `.env`
- `~/.hermes/.env`
- API Key、DingTalk Client Secret、Token、Webhook 等真实密钥

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
    ├── check_gateway.sh
    ├── install_launch_agent.sh
    ├── install_mac.sh
    ├── start_gateway_tmux.sh
    └── uninstall_launch_agent.sh
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

## 二、填写模型和钉钉配置

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

至少填写：

```env
OPENROUTER_API_KEY=你的模型APIKey
DINGTALK_CLIENT_ID=你的钉钉应用ClientID或AppKey
DINGTALK_CLIENT_SECRET=你的钉钉应用ClientSecret或AppSecret
DINGTALK_ALLOWED_USERS=*
```

说明：

- `DINGTALK_ALLOWED_USERS=*` 只建议迁移测试时临时使用。
- 长期运行建议改成指定钉钉用户 ID 或 Hermes 日志里的 `sender_id`，多个值用英文逗号分隔。
- 当前 Windows 电脑上已有的 `.env` 不要通过 GitHub 迁移，可用 U 盘、局域网传输，或者在 Mac 上手动重填。

## 三、初始化 Hermes

执行：

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
hermes setup
hermes model
hermes status --all
```

如果 `hermes setup` 已经做过，可以跳过。第一次迁移建议完整执行一遍，确认模型和钉钉配置都能被 Hermes 识别。

## 四、第一次前台测试钉钉连接

先前台运行，便于看到报错：

```bash
hermes gateway run
```

看到类似 `Connected via Stream Mode` 后，在钉钉里给机器人发消息测试。确认可用后，按 `Ctrl+C` 停止前台进程。

## 五、长期后台运行

推荐用 tmux，让 Hermes 在终端关闭后继续运行：

```bash
cd ~/Hermes
bash scripts/start_gateway_tmux.sh
```

查看状态：

```bash
bash scripts/check_gateway.sh
```

进入后台会话：

```bash
tmux attach -t hermes-gateway
```

退出 tmux 但保持 Hermes 运行：先按 `Ctrl+B`，再按 `D`。

重启后台网关：

```bash
tmux kill-session -t hermes-gateway
bash ~/Hermes/scripts/start_gateway_tmux.sh
```

## 六、开机自启动，可选

先确认手动运行稳定，再启用开机自启动：

```bash
cd ~/Hermes
bash scripts/install_launch_agent.sh
```

查看：

```bash
launchctl list | grep hermes
bash ~/Hermes/scripts/check_gateway.sh
```

取消开机自启动：

```bash
cd ~/Hermes
bash scripts/uninstall_launch_agent.sh
```

## 七、从旧电脑迁移配置

可迁移的本地文件：

```text
旧电脑 ~/.hermes/config.yaml  -> Mac ~/.hermes/config.yaml
旧电脑 ~/.hermes/.env         -> Mac ~/.hermes/.env
```

注意：`.env` 含真实密钥，不要经过 GitHub。

更稳妥的做法是在 Mac 上重新填写 `~/.hermes/.env`，只复制必要的 Key。

## 八、Mac 不要睡眠

Hermes 需要 Mac 保持在线。建议：

- Mac 插电运行。
- 系统设置里关闭自动睡眠，或设置为长期唤醒。
- 合盖可能会睡眠，尽量开盖或接显示器长期运行。

临时保持唤醒：

```bash
caffeinate -dimsu
```

## 九、常见问题

### 1. 钉钉没有回复

执行：

```bash
bash ~/Hermes/scripts/check_gateway.sh
```

如果日志出现 `Unauthorized user: xxx on dingtalk`，把 `xxx` 加进：

```bash
nano ~/.hermes/.env
```

然后重启网关：

```bash
tmux kill-session -t hermes-gateway
bash ~/Hermes/scripts/start_gateway_tmux.sh
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

### 3. Homebrew 安装很慢或失败

确认 Mac 可以访问 GitHub 和 Homebrew，然后重新执行：

```bash
bash ~/Hermes/scripts/install_mac.sh
```

### 4. 开机自启动没有起来

查看日志：

```bash
tail -100 ~/.hermes/logs/launchd-gateway.out.log
tail -100 ~/.hermes/logs/launchd-gateway.err.log
```

也可以先取消自启动，再重新安装：

```bash
cd ~/Hermes
bash scripts/uninstall_launch_agent.sh
bash scripts/install_launch_agent.sh
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
