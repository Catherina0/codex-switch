#!/usr/bin/env bash
set -euo pipefail

PROGRAM_NAME="codex-switch"
REPO="${CODEX_SWITCH_REPO:-Catherina0/codex-switch}"
REF="${CODEX_SWITCH_REF:-main}"
BASE_URL="${CODEX_SWITCH_BASE_URL:-https://raw.githubusercontent.com/$REPO/$REF}"
INSTALL_DIR="${INSTALL_DIR:-"$HOME/.local/bin"}"
TARGET_FILE="$INSTALL_DIR/$PROGRAM_NAME"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'install.sh: %s\n' "$*" >&2
  exit 1
}

download() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$output" "$url"
  else
    fail "curl or wget is required to download $PROGRAM_NAME"
  fi
}

local_source_file() {
  local source="${BASH_SOURCE[0]:-}"
  local dir

  if [[ -n "$source" && -f "$source" ]]; then
    dir="$(cd "$(dirname "$source")" && pwd)"
    if [[ -f "$dir/bin/$PROGRAM_NAME" ]]; then
      printf '%s/bin/%s\n' "$dir" "$PROGRAM_NAME"
      return 0
    fi
  fi

  return 1
}

install_from_local_file() {
  local source_file="$1"

  mkdir -p "$INSTALL_DIR"
  cp "$source_file" "$TARGET_FILE"
  chmod 0755 "$TARGET_FILE"
}

install_from_remote() {
  local tmp_file

  tmp_file="$(mktemp)"
  trap 'rm -f "$tmp_file"' EXIT
  download "$BASE_URL/bin/$PROGRAM_NAME" "$tmp_file"

  mkdir -p "$INSTALL_DIR"
  cp "$tmp_file" "$TARGET_FILE"
  chmod 0755 "$TARGET_FILE"
}

print_path_hint() {
  case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
      log ""
      log "$INSTALL_DIR is not currently in PATH."
      log "Add this line to your shell profile, then restart your terminal:"
      log "  export PATH=\"$INSTALL_DIR:\$PATH\""
      ;;
  esac
}

main() {
  local source_file=""

  if source_file="$(local_source_file)"; then
    install_from_local_file "$source_file"
  else
    install_from_remote
  fi

  log "Installed $PROGRAM_NAME to $TARGET_FILE"
  "$TARGET_FILE" --version
  print_path_hint
}

main "$@"
