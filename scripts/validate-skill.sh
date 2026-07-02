#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_dir="$repo_root/multi-agent-handoff"
skill_file="$skill_dir/SKILL.md"
commands_dir="$skill_dir/commands"
errors=()

require_path() {
  local path="$1"
  local label="$2"
  if [ ! -e "$path" ]; then
    errors+=("Missing $label: $path")
  fi
}

require_grep() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if ! grep -Eq "$pattern" "$path"; then
    errors+=("Missing $label")
  fi
}

require_path "$skill_file" "SKILL.md"
require_path "$commands_dir" "commands directory"

if [ -f "$skill_file" ]; then
  require_grep '^name:[[:space:]]*multi-agent-handoff[[:space:]]*$' "$skill_file" "SKILL.md name frontmatter"
  require_grep '^description:[[:space:]]*.+' "$skill_file" "SKILL.md description frontmatter"
  require_grep '^## Explore-First Policy$' "$skill_file" "Explore-First Policy"
  require_grep '^## Light Vs Full Handoff$' "$skill_file" "Light Vs Full Handoff"
  require_grep '^## Filesystem Operations Checklist$' "$skill_file" "Filesystem Operations Checklist"

  while IFS= read -r command_name; do
    [ -n "$command_name" ] || continue
    require_path "$commands_dir/$command_name" "declared command $command_name"
  done < <(grep -Eo 'Read `commands/[^`]+\.md`' "$skill_file" | sed -E 's/.*commands\/([^`]+).*/\1/' | sort -u)
fi

init_command="$commands_dir/inithandoff.md"
require_path "$init_command" "inithandoff command"
if [ -f "$init_command" ]; then
  require_grep 'Filesystem Operations Checklist' "$init_command" "inithandoff checklist reference"
fi

for example_path in \
  "examples/basic-handoff/HandoffDocs/handoff.md" \
  "examples/basic-handoff/HandoffDocs/handoffs/api-auth-investigation.md" \
  "examples/light-handoff/HandoffDocs/light/api-auth-investigation.md" \
  "examples/explore-output.md" \
  "examples/light-handoffprompt-output.md" \
  "examples/compact-history/HandoffDocs/artifacts/api-auth-investigation/reports/20260702-101500-compact-history.md" \
  "examples/handoffprompt-output.md"; do
  require_path "$repo_root/$example_path" "example $example_path"
done

if [ "${#errors[@]}" -gt 0 ]; then
  printf 'Skill validation failed:\n' >&2
  for error in "${errors[@]}"; do
    printf ' - %s\n' "$error" >&2
  done
  exit 1
fi

printf 'Skill validation passed.\n'
