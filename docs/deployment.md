# Deployment Guide

This guide explains how to publish `codex-switch` as a small open-source GitHub project.

## 1. Verify Locally

From the project root:

```bash
make test
make dist
```

Expected outputs:

```text
All tests passed.
dist/codex-switch-0.1.1.tar.gz
dist/codex-switch-0.1.1.zip
```

The `.zip` artifact is created only when `zip` is installed.

## 2. Create the Git Repository

```bash
cd /Users/catherina/Documents/GitHub/codex-switch
git init
git add .
git commit -m "Initial release"
```

## 3. Create the GitHub Repository

With GitHub CLI:

```bash
gh repo create Catherina0/codex-switch \
  --public \
  --source=. \
  --remote=origin \
  --push
```

Without GitHub CLI:

1. Create a new public GitHub repository named `codex-switch`.
2. Add the remote:

   ```bash
   git remote add origin git@github.com:Catherina0/codex-switch.git
   git branch -M main
   git push -u origin main
   ```

If the repository owner is not `Catherina0`, update these places before publishing:

- `README.md` one-line install URL
- `install.sh` default `CODEX_SWITCH_REPO`
- this deployment guide

Users can override the repository without editing files:

```bash
CODEX_SWITCH_REPO=owner/codex-switch \
  curl -fsSL https://raw.githubusercontent.com/owner/codex-switch/main/install.sh | bash
```

## 4. Create a Release

```bash
make dist
gh release create v0.1.1 \
  dist/codex-switch-0.1.1.tar.gz \
  dist/codex-switch-0.1.1.zip \
  --title "codex-switch v0.1.1" \
  --notes "Adds automatic Codex restart after switching modes."
```

If the `.zip` file does not exist, omit it from the release command.

## 5. Installation Smoke Test

In a clean shell:

```bash
curl -fsSL https://raw.githubusercontent.com/Catherina0/codex-switch/main/install.sh | bash
codex-switch --version
codex-switch status
```

For a test repository or branch:

```bash
CODEX_SWITCH_REPO=Catherina0/codex-switch CODEX_SWITCH_REF=main \
  bash install.sh
```

## 6. CI

If you add GitHub Actions later, use a token with `workflow` permission and run:

```bash
make test
```
