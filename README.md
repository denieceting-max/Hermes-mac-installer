# Hermes Mac 部署安装包

用途：把 Hermes 从 Windows/WSL 迁移到一台长期不关机的 Mac 上运行，并连接钉钉 Stream Mode。

## 重要安全说明

本仓库不要提交真实密钥。

不要把以下文件推送到 GitHub：

- `.env`
- `~/.hermes/.env`
- 任何包含 API Key、Client Secret、Token 的文件

本包只提供模板：

- `config/.env.example`
- `config/config.example.yaml`

真实密钥请在 Mac 上本地填写。

## 包内文件

```text
Hermes/
├── README.md
├── .gitignore
├── config/
│   ├── .env.example
│   └── config.example.yaml
└── scripts/
    ├── install_mac.sh
    ├── start_gateway_tmux.sh
    └── check_gateway.sh
```

## 一、把这个包推送到 GitHub

在 Windows/WSL 当前电脑执行：

```bash
cd /mnt/d/MyWebProject/Hermes
git init
git add README.md .gitignore config scripts docs
git commit -m "chore: add Hermes Mac installer"
```

然后在 GitHub 新建仓库，把 GitHub 给你的 remote 命令复制进来执行，例如：

```bash
git remote add origin https://github.com/你的账号/你的仓库名.git
git branch -M main
git push -u origin main
```

`git push` 属于敏感操作，建议你自己执行。

## 二、Mac 上下载安装

在新 Mac 打开“终端”，执行：

```bash
cd ~
git clone https://github.com/你的账号/你的仓库名.git Hermes
cd Hermes
bash scripts/install_mac.sh
```

如果 Mac 没装 Apple Command Line Tools，脚本会提示你先执行：

```bash
xcode-select --install
```

完成后重新运行：

```bash
cd ~/Hermes
bash scripts/install_mac.sh
```

## 三、填写 Hermes 和钉钉密钥

安装脚本会创建：

```bash
~/.hermes/.env
~/.hermes/config.yaml
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

- `DINGTALK_ALLOWED_USERS=*` 只适合临时测试。
- 正式使用建议改成允许的钉钉用户 ID 或 Hermes 日志里识别到的 runtime sender_id，多个值用英文逗号分隔。

## 四、初始化 Hermes 配置

执行：

```bash
hermes setup
hermes model
hermes status --all
```

## 五、启动钉钉网关

前台启动，适合第一次测试：

```bash
hermes gateway run
```

看到类似 `Connected via Stream Mode` 后，在钉钉里给机器人发消息测试。

## 六、长期后台运行

推荐用 tmux：

```bash
cd ~/Hermes
bash scripts/start_gateway_tmux.sh
```

查看运行状态：

```bash
tmux capture-pane -t hermes-gateway -p | tail -80
```

进入后台会话：

```bash
tmux attach -t hermes-gateway
```

退出 tmux 但保持 Hermes 运行：先按 `Ctrl+B`，再按 `D`。

检查钉钉连接和日志：

```bash
bash scripts/check_gateway.sh
```

## 七、开机自启动，可选

先确认手动运行稳定，再做这一步。

创建文件：

```bash
mkdir -p ~/Library/LaunchAgents
nano ~/Library/LaunchAgents/com.hermes.gateway.plist
```

写入以下内容，把 `你的用户名` 改成 Mac 用户名：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.hermes.gateway</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"; hermes gateway run</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/Users/你的用户名/.hermes/logs/launchd-gateway.out.log</string>
  <key>StandardErrorPath</key>
  <string>/Users/你的用户名/.hermes/logs/launchd-gateway.err.log</string>
</dict>
</plist>
```

加载服务：

```bash
launchctl load ~/Library/LaunchAgents/com.hermes.gateway.plist
launchctl start com.hermes.gateway
```

查看：

```bash
launchctl list | grep hermes
bash ~/Hermes/scripts/check_gateway.sh
```

停止：

```bash
launchctl stop com.hermes.gateway
launchctl unload ~/Library/LaunchAgents/com.hermes.gateway.plist
```

## 八、从旧电脑迁移现有配置

如果要保留当前 Windows/WSL 机器的 Hermes 配置，可手动复制以下文件到 Mac：

```text
旧电脑 ~/.hermes/config.yaml  -> Mac ~/.hermes/config.yaml
旧电脑 ~/.hermes/.env         -> Mac ~/.hermes/.env
```

注意：`.env` 含真实密钥，不要经过 GitHub。可用 U 盘、局域网临时传输，或直接在 Mac 手动重新填写。

## 九、常见问题

### 1. 钉钉没有回复

执行：

```bash
bash scripts/check_gateway.sh
```

如果出现 `Unauthorized user: xxx on dingtalk`，把 `xxx` 加进：

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

也可以关闭终端重新打开。

### 3. Mac 合盖睡眠

Mac 合盖可能会睡眠，Hermes 会断。建议插电运行，并关闭自动睡眠。临时保持唤醒：

```bash
caffeinate -dimsu
```
