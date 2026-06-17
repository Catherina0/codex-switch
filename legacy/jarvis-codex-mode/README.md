# Codex Mode Switcher

一个小工具，用来在 Codex 的 API 登录模式和 ChatGPT/OpenAI 订阅模式之间切换。

它只切换两个文件：

- `~/.codex/config.toml`
- `~/.codex/auth.json`

你可以把两套配置保存成：

- API 模式：`config.toml.api`、`auth.json.api`
- 订阅模式：`config.toml.openai`、`auth.json.openai`

如果你已经用的是 `.oai` 后缀，也不用改名，工具会自动识别：

- `config.toml.oai`
- `auth.json.oai`

## 安装

```bash
./bin/codex-mode install
```

如果提示 `codex-mode` 找不到，把这一行加到 `~/.zshrc`：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

然后重新打开终端，或运行：

```bash
source ~/.zshrc
```

## 日常切换

切到 API 模式：

```bash
codex-mode api
```

切到订阅模式：

```bash
codex-mode openai
```

查看当前状态：

```bash
codex-mode status
```

检查两套文件是否都准备好了：

```bash
codex-mode doctor
```

每次切换前，工具都会给当前生效的 `config.toml` 和 `auth.json` 自动做一份带时间戳的备份。

## 初始设置

如果你已经有 `.api` 和 `.openai` / `.oai` 两套文件，直接运行 `codex-mode status` 看一下即可。

如果还没有备份文件，可以这样建：

1. 先让 Codex 处于 API 登录状态。
2. 运行：

   ```bash
   codex-mode init api
   ```

3. 再让 Codex 处于订阅登录状态。
4. 运行：

   ```bash
   codex-mode init openai
   ```

如果要沿用 `.oai` 后缀：

```bash
codex-mode init oai
```

如果目标备份文件已经存在，工具默认不会覆盖。确认要覆盖时加：

```bash
codex-mode init api --force
codex-mode init openai --force
```
