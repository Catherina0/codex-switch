# codex-switch

[English](README.md)

`codex-switch` 是一个零依赖的小型命令行工具，用来在两套 Codex 登录方式之间切换：

- API key 模式
- OAI / ChatGPT 订阅登录模式

它会切换这些当前生效的 Codex 文件：

- `~/.codex/config.toml`
- `~/.codex/auth.json`

对应的保存文件是：

- API 模式：`config.toml.api` 和 `auth.json.api`
- OAI 模式：`config.toml.oai` 和 `auth.json.oai`
- 兼容文件：也支持 `config.toml.openai` 和 `auth.json.openai`

## 安装

一行安装：

```bash
curl -fsSL https://raw.githubusercontent.com/Catherina0/codex-switch/main/install.sh | bash
```

如果安装后找不到 `codex-switch`，把下面这行加入你的 shell 配置文件：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

然后重启终端，或者运行：

```bash
source ~/.zshrc
```

也可以从仓库克隆后安装：

```bash
git clone https://github.com/Catherina0/codex-switch.git
cd codex-switch
make install
```

## 快速开始

先保存当前正在使用的登录模式：

```bash
codex-switch init
```

工具会询问：

```text
Which mode are the current active Codex files using?
  1) oai - ChatGPT/OAI subscription login
  2) api    - API key login
Choose [1/oai, 2/api]:
```

然后切到另一种 Codex 登录方式，再运行一次：

```bash
codex-switch init
```

检查两种模式是否都准备好了：

```bash
codex-switch doctor
```

日常切换：

```bash
codex-switch api
codex-switch oai
```

切换成功后，`codex-switch` 会自动重启 Codex，让新的登录文件立即生效。

需要跳过重启时：

```bash
codex-switch --no-restart api
CODEX_SWITCH_RESTART=0 codex-switch oai
```

查看当前状态：

```bash
codex-switch status
```

## 非交互设置

如果你已经知道当前生效文件属于哪种模式，可以直接指定：

```bash
codex-switch init api
codex-switch init oai
```

覆盖已有的保存文件：

```bash
codex-switch init api --force
codex-switch init oai
```

旧的 `openai` 命令名仍然是别名，但新的用法建议使用 `oai`。

## 自定义 Codex 目录

默认情况下，Codex 文件位于 `~/.codex`。

可以使用 `CODEX_HOME`：

```bash
CODEX_HOME=/path/to/.codex codex-switch status
```

也可以使用 `--codex-home`：

```bash
codex-switch --codex-home /path/to/.codex status
codex-switch --codex-home /path/to/.codex oai
```

支持带空格的路径。

## 安全性

切换模式前，`codex-switch` 会给当前生效文件创建带时间戳的备份：

```text
config.toml.backup-YYYYMMDD-HHMMSS-before-api
auth.json.backup-YYYYMMDD-HHMMSS-before-api
```

它不会打印 `config.toml` 或 `auth.json` 的内容。

## 命令

```bash
codex-switch status
codex-switch init
codex-switch init api
codex-switch init oai
codex-switch switch api
codex-switch switch oai
codex-switch --no-restart api
codex-switch api
codex-switch oai
codex-switch doctor
codex-switch --version
codex-switch --help
```

## 测试

```bash
make test
```

测试套件覆盖：

- 交互式初始化
- 非交互初始化
- 两种模式的切换
- 切换后的 Codex 自动重启
- 带时间戳的备份
- `.oai` 模式文件和 `.openai` 兼容文件
- 缺失模式时失败且不修改当前文件
- 带空格的路径
- `CODEX_HOME`
- `--codex-home`

## 打包

```bash
make dist
```

发布包会生成到 `dist/`。

## 卸载

```bash
rm -f "$HOME/.local/bin/codex-switch"
```

或者在克隆仓库里运行：

```bash
make uninstall
```
