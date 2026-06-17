#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT_DIR/bin/codex-switch"
TMP_ROOT="$(mktemp -d)"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

log_ok() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf 'ok %s - %s\n' "$PASS_COUNT" "$1"
}

log_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf 'not ok %s - %s\n' "$((PASS_COUNT + FAIL_COUNT))" "$1" >&2
}

run_test() {
  local name="$1"
  shift

  if "$@"; then
    log_ok "$name"
  else
    log_fail "$name"
  fi
}

new_codex_home() {
  local name="$1"
  local dir="$TMP_ROOT/$name/codex home"

  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

write_active() {
  local home_dir="$1"
  local config_content="$2"
  local auth_content="$3"

  printf '%s\n' "$config_content" > "$home_dir/config.toml"
  printf '%s\n' "$auth_content" > "$home_dir/auth.json"
}

assert_file_content() {
  local file="$1"
  local expected="$2"
  local actual

  actual="$(cat "$file")"
  [[ "$actual" == "$expected" ]]
}

assert_contains() {
  local haystack="$1"
  local needle="$2"

  [[ "$haystack" == *"$needle"* ]]
}

assert_backup_exists() {
  local home_dir="$1"
  local file_name="$2"
  local mode="$3"
  local matches

  shopt -s nullglob
  matches=("$home_dir/$file_name".backup-*-before-"$mode")
  shopt -u nullglob

  [[ "${#matches[@]}" -ge 1 ]]
}

test_help_version_and_syntax() {
  bash -n "$BIN"
  "$BIN" --help >/dev/null
  "$BIN" --version | grep -Eq '^codex-switch [0-9]+\.[0-9]+\.[0-9]+$'
}

test_init_switch_and_backups_with_spaced_path() {
  local home_dir output
  home_dir="$(new_codex_home "switch spaced")"

  write_active "$home_dir" "api-config" "api-auth"
  "$BIN" --codex-home "$home_dir" init api >/dev/null

  write_active "$home_dir" "oai-config" "oai-auth"
  "$BIN" --codex-home "$home_dir" init oai >/dev/null

  output="$("$BIN" --codex-home "$home_dir" status)"
  assert_contains "$output" "Active mode: oai (oai)"

  "$BIN" --codex-home "$home_dir" api >/dev/null
  assert_file_content "$home_dir/config.toml" "api-config"
  assert_file_content "$home_dir/auth.json" "api-auth"
  assert_backup_exists "$home_dir" "config.toml" "api"
  assert_backup_exists "$home_dir" "auth.json" "api"

  output="$("$BIN" --codex-home "$home_dir" status)"
  assert_contains "$output" "Active mode: api (api)"
}

test_interactive_init_from_stdin_and_force_after_mode() {
  local home_dir
  home_dir="$(new_codex_home "interactive init")"

  write_active "$home_dir" "oai-config-v1" "oai-auth-v1"
  printf '1\n' | "$BIN" --codex-home "$home_dir" init >/dev/null
  assert_file_content "$home_dir/config.toml.oai" "oai-config-v1"
  assert_file_content "$home_dir/auth.json.oai" "oai-auth-v1"

  write_active "$home_dir" "oai-config-v2" "oai-auth-v2"
  "$BIN" --codex-home "$home_dir" init oai --force >/dev/null
  assert_file_content "$home_dir/config.toml.oai" "oai-config-v2"
  assert_file_content "$home_dir/auth.json.oai" "oai-auth-v2"
}

test_oai_mode_is_supported() {
  local home_dir output
  home_dir="$(new_codex_home "oai")"

  write_active "$home_dir" "api-config" "api-auth"
  cp "$home_dir/config.toml" "$home_dir/config.toml.api"
  cp "$home_dir/auth.json" "$home_dir/auth.json.api"
  printf 'oai-config\n' > "$home_dir/config.toml.oai"
  printf 'oai-auth\n' > "$home_dir/auth.json.oai"

  "$BIN" --codex-home "$home_dir" oai >/dev/null
  assert_file_content "$home_dir/config.toml" "oai-config"
  assert_file_content "$home_dir/auth.json" "oai-auth"

  output="$("$BIN" --codex-home "$home_dir" status)"
  assert_contains "$output" "Active mode: oai (oai)"
}

test_openai_alias_files_are_supported() {
  local home_dir output
  home_dir="$(new_codex_home "openai alias")"

  write_active "$home_dir" "api-config" "api-auth"
  cp "$home_dir/config.toml" "$home_dir/config.toml.api"
  cp "$home_dir/auth.json" "$home_dir/auth.json.api"
  printf 'alias-config\n' > "$home_dir/config.toml.openai"
  printf 'alias-auth\n' > "$home_dir/auth.json.openai"

  "$BIN" --codex-home "$home_dir" oai >/dev/null
  assert_file_content "$home_dir/config.toml" "alias-config"
  assert_file_content "$home_dir/auth.json" "alias-auth"

  output="$("$BIN" --codex-home "$home_dir" status)"
  assert_contains "$output" "Active mode: oai (openai)"
}

test_missing_saved_mode_fails_without_mutating() {
  local home_dir
  home_dir="$(new_codex_home "missing mode")"

  write_active "$home_dir" "active-config" "active-auth"

  if "$BIN" --codex-home "$home_dir" api >/dev/null 2>&1; then
    return 1
  fi

  assert_file_content "$home_dir/config.toml" "active-config"
  assert_file_content "$home_dir/auth.json" "active-auth"
}

test_doctor_accepts_ready_home() {
  local home_dir
  home_dir="$(new_codex_home "doctor")"

  write_active "$home_dir" "api-config" "api-auth"
  "$BIN" --codex-home "$home_dir" init api >/dev/null
  write_active "$home_dir" "oai-config" "oai-auth"
  "$BIN" --codex-home "$home_dir" init oai >/dev/null

  "$BIN" --codex-home "$home_dir" doctor >/dev/null
}

test_env_codex_home_and_tilde_option() {
  local home_dir output
  home_dir="$(new_codex_home "env home")"

  write_active "$home_dir" "api-config" "api-auth"
  CODEX_HOME="$home_dir" "$BIN" init api >/dev/null
  output="$(CODEX_HOME="$home_dir" "$BIN" status)"
  assert_contains "$output" "Active mode: api (api)"

  "$BIN" --codex-home "~/.codex" status >/dev/null || true
}

run_test "help, version, and syntax" test_help_version_and_syntax
run_test "init, switch, backups, and paths with spaces" test_init_switch_and_backups_with_spaced_path
run_test "interactive init and --force after mode" test_interactive_init_from_stdin_and_force_after_mode
run_test ".oai files are supported" test_oai_mode_is_supported
run_test ".openai compatibility files are supported" test_openai_alias_files_are_supported
run_test "missing saved mode fails without mutating active files" test_missing_saved_mode_fails_without_mutating
run_test "doctor accepts a ready Codex home" test_doctor_accepts_ready_home
run_test "CODEX_HOME env and tilde option work" test_env_codex_home_and_tilde_option

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf '%s test(s) failed\n' "$FAIL_COUNT" >&2
  exit 1
fi

printf 'All %s tests passed.\n' "$PASS_COUNT"
