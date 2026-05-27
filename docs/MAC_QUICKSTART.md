# Mac 快速操作清单

目标：不用打开终端也能和 Hermes 对话。安装完成后用浏览器打开 Hermes Dashboard。

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

## 2. 填写模型密钥

```bash
nano ~/.hermes/.env
```

至少填写一个模型 API Key，例如：

```env
OPENROUTER_API_KEY=你的模型APIKey
```

不用钉钉时，`DINGTALK_CLIENT_ID`、`DINGTALK_CLIENT_SECRET` 可以保持空白。

保存 nano：按 `Ctrl+O`，回车，再按 `Ctrl+X`。

## 3. 初始化 Hermes

```bash
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
hermes setup
hermes model
hermes status --all
```

## 4. 启动浏览器聊天页面

```bash
cd ~/Hermes
bash scripts/start_dashboard.sh
```

打开：

```text
http://127.0.0.1:9119
```

## 5. 设置开机自启动

```bash
cd ~/Hermes
bash scripts/install_dashboard_launch_agent.sh
```

取消自启动：

```bash
cd ~/Hermes
bash scripts/uninstall_dashboard_launch_agent.sh
```

## 6. 创建应用快捷方式

```bash
cd ~/Hermes
bash scripts/create_dashboard_shortcut.sh
```

以后可以在 Finder 的 Applications 或 Spotlight 搜索 `Hermes Dashboard` 打开。

## 7. 常用排查命令

```bash
bash ~/Hermes/scripts/check_dashboard.sh
tail -100 ~/.hermes/logs/dashboard.log
tail -100 ~/.hermes/logs/dashboard-launchd.err.log
```

## 8. 可选钉钉

只想用浏览器聊天时，不需要启动钉钉 gateway。以后需要钉钉时再手动执行：

```bash
cd ~/Hermes
bash scripts/start_gateway_tmux.sh
```
