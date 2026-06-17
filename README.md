# codex-switch

[中文说明](README.zh-CN.md)

`codex-switch` is a tiny zero-dependency CLI for switching Codex between:

- API key mode
- OAI subscription login mode

It swaps these active Codex files:

- `~/.codex/config.toml`
- `~/.codex/auth.json`

with saved mode files:

- API mode: `config.toml.api` and `auth.json.api`
- OAI mode: `config.toml.oai` and `auth.json.oai`
- Compatibility files: `config.toml.openai` and `auth.json.openai` are also supported

## Install

One-line install:

```bash
curl -fsSL https://raw.githubusercontent.com/Catherina0/codex-switch/main/install.sh | bash
```

If `codex-switch` is not found after installation, add this to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then restart the terminal or run:

```bash
source ~/.zshrc
```

You can also install from a clone:

```bash
git clone https://github.com/Catherina0/codex-switch.git
cd codex-switch
make install
```

## Quick Start

First, save the mode you are currently logged in with:

```bash
codex-switch init
```

The tool will ask:

```text
Which mode are the current active Codex files using?
  1) oai - ChatGPT/OAI subscription login
  2) api    - API key login
Choose [1/oai, 2/api]:
```

Then log in with the other Codex mode and run the same command again:

```bash
codex-switch init
```

Check that both modes are ready:

```bash
codex-switch doctor
```

Daily switching:

```bash
codex-switch api
codex-switch oai
```

Check current status:

```bash
codex-switch status
```

## Non-Interactive Setup

For scripts or users who already know the current active mode:

```bash
codex-switch init api
codex-switch init oai
```

Overwrite an existing saved mode:

```bash
codex-switch init api --force
codex-switch init oai
```

The older `openai` command name remains an alias, but new usage should prefer `oai`.

## Custom Codex Directory

By default, Codex files live in `~/.codex`.

Use `CODEX_HOME`:

```bash
CODEX_HOME=/path/to/.codex codex-switch status
```

Or use `--codex-home`:

```bash
codex-switch --codex-home /path/to/.codex status
codex-switch --codex-home /path/to/.codex oai
```

Paths with spaces are supported.

## Safety

Before switching modes, `codex-switch` backs up the active files with a timestamp:

```text
config.toml.backup-YYYYMMDD-HHMMSS-before-api
auth.json.backup-YYYYMMDD-HHMMSS-before-api
```

It never prints the contents of `config.toml` or `auth.json`.

## Commands

```bash
codex-switch status
codex-switch init
codex-switch init api
codex-switch init oai
codex-switch switch api
codex-switch switch oai
codex-switch api
codex-switch oai
codex-switch doctor
codex-switch --version
codex-switch --help
```

## Test

```bash
make test
```

The test suite covers:

- interactive initialization
- non-interactive initialization
- switching both modes
- timestamped backups
- `.oai` mode files and `.openai` compatibility files
- missing mode failure behavior
- paths with spaces
- `CODEX_HOME`
- `--codex-home`

## Package

```bash
make dist
```

Release artifacts are written to `dist/`.

## Uninstall

```bash
rm -f "$HOME/.local/bin/codex-switch"
```

Or, from a clone:

```bash
make uninstall
```
