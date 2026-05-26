# Mac 快速操作清单

适合在新 Mac 上照着执行。

## 1. 下载安装包

```bash
cd ~
git clone https://github.com/denieceting-max/Hermes-mac-installer.git Hermes
cd Hermes
bash scripts/install_mac.sh
```

如果提示安装 Apple Command Line Tools：

```bash
xcode-select --install
```

安装完成后重新运行：

```bash
cd ~/Hermes
bash scripts/install_mac.sh
```

## 2. 填写密钥

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

保存 nano：按 `Ctrl+O`，回车，再按 `Ctrl+X`。

## 3. 初始化 Hermes

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
hermes setup
hermes model
hermes status --all
```

## 4. 前台测试钉钉网关

```bash
hermes gateway run
```

看到 `Connected via Stream Mode` 后，到钉钉里给机器人发消息测试。测试成功后按 `Ctrl+C` 停止。

## 5. 后台长期运行

```bash
cd ~/Hermes
bash scripts/start_gateway_tmux.sh
bash scripts/check_gateway.sh
```

进入后台会话：

```bash
tmux attach -t hermes-gateway
```

退出 tmux 但保持运行：先按 `Ctrl+B`，再按 `D`。

## 6. 可选：开机自启动

确认后台运行稳定后：

```bash
cd ~/Hermes
bash scripts/install_launch_agent.sh
```

取消自启动：

```bash
cd ~/Hermes
bash scripts/uninstall_launch_agent.sh
```

## 7. 常用排查命令

```bash
bash ~/Hermes/scripts/check_gateway.sh
tmux capture-pane -t hermes-gateway -p | tail -80
tail -100 ~/.hermes/logs/gateway.log
launchctl list | grep hermes
```
