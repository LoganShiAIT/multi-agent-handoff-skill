#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_source="$repo_root/multi-agent-handoff"
command_source="$skill_source/commands"
codex_skills_dir="${CODEX_HOME:-$HOME/.codex}/skills"
claude_commands_dir=""
mode="copy"
dry_run=0

say() {
  printf '[multi-agent-handoff] %s\n' "$1"
}

usage() {
  cat <<'USAGE'
Usage: scripts/install.sh [options]

Options:
  --codex-dir DIR             Codex skills directory. Default: ${CODEX_HOME:-$HOME/.codex}/skills
  --claude-commands-dir DIR   Sync command markdown files to a Claude commands directory, e.g. .claude/commands
  --mode copy|link            Install mode. Default: copy
  --dry-run                   Print actions without changing files
  -h, --help                  Show this help
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex-dir)
      codex_skills_dir="$2"
      shift 2
      ;;
    --claude-commands-dir)
      claude_commands_dir="$2"
      shift 2
      ;;
    --mode)
      mode="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
done

if [ "$mode" != "copy" ] && [ "$mode" != "link" ]; then
  printf 'Invalid --mode: %s\n' "$mode" >&2
  exit 2
fi

if [ ! -d "$skill_source" ]; then
  printf 'Skill source not found: %s\n' "$skill_source" >&2
  exit 1
fi

ensure_dir() {
  if [ "$dry_run" -eq 1 ]; then
    say "would create directory: $1"
  else
    mkdir -p "$1"
  fi
}

install_path() {
  local source="$1"
  local target="$2"
  local directory="$3"
  ensure_dir "$(dirname "$target")"

  if [ "$dry_run" -eq 1 ]; then
    say "would install $source -> $target ($mode)"
    return
  fi

  rm -rf "$target"
  if [ "$mode" = "link" ]; then
    ln -s "$source" "$target"
  elif [ "$directory" = "1" ]; then
    cp -R "$source" "$target"
  else
    cp "$source" "$target"
  fi
}

skill_target="$codex_skills_dir/multi-agent-handoff"
install_path "$skill_source" "$skill_target" 1
if [ "$dry_run" -eq 1 ]; then
  say "would finish skill install to $skill_target"
else
  say "installed skill to $skill_target"
fi

if [ -n "$claude_commands_dir" ]; then
  ensure_dir "$claude_commands_dir"
  for command_file in "$command_source"/*.md; do
    install_path "$command_file" "$claude_commands_dir/$(basename "$command_file")" 0
  done
  if [ "$dry_run" -eq 1 ]; then
    say "would finish Claude command sync to $claude_commands_dir"
  else
    say "synced Claude commands to $claude_commands_dir"
  fi
else
  say "skipped Claude command sync; pass --claude-commands-dir .claude/commands to enable it"
fi
