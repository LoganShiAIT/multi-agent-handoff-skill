#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_dir="$repo_root/multi-agent-handoff"
skill_file="$skill_dir/SKILL.md"
commands_dir="$skill_dir/commands"
references_dir="$skill_dir/references"
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
require_path "$references_dir" "references directory"

declared_commands=()
if [ -f "$skill_file" ]; then
  require_grep '^name:[[:space:]]*multi-agent-handoff[[:space:]]*$' "$skill_file" "SKILL.md name frontmatter"
  require_grep '^description:[[:space:]]*.+' "$skill_file" "SKILL.md description frontmatter"
  require_grep '^## Lazy Command Routing$' "$skill_file" "Lazy Command Routing"

  skill_size="$(wc -c < "$skill_file" | tr -d '[:space:]')"
  if [ "$skill_size" -gt 8192 ]; then
    errors+=("SKILL.md is too large: ${skill_size} bytes > 8192 bytes")
  fi

  while IFS= read -r command_name; do
    [ -n "$command_name" ] || continue
    declared_commands+=("$command_name")
    require_path "$commands_dir/$command_name" "declared command $command_name"
  done < <(grep -Eo 'Read `commands/[^`]+\.md`' "$skill_file" | sed -E 's/.*commands\/([^`]+).*/\1/' | sort -u)
fi

if [ -d "$commands_dir" ]; then
  for command_file in "$commands_dir"/*.md; do
    [ -e "$command_file" ] || continue
    require_grep '^## Required References$' "$command_file" "$(basename "$command_file") Required References section"

    command_name="$(basename "$command_file")"
    routed=false
    for declared_command in "${declared_commands[@]}"; do
      if [ "$declared_command" = "$command_name" ]; then
        routed=true
        break
      fi
    done
    if [ "$routed" = false ]; then
      errors+=("Command file is not routed from SKILL.md: $command_name")
    fi
  done
fi

if [ -f "$skill_file" ] || [ -d "$commands_dir" ]; then
  while IFS= read -r reference_name; do
    [ -n "$reference_name" ] || continue
    require_path "$references_dir/$reference_name" "declared reference $reference_name"
  done < <(
    {
      [ -f "$skill_file" ] && grep -Eho '`references/[^`]+\.md`' "$skill_file" || true
      [ -d "$commands_dir" ] && grep -Eho '`references/[^`]+\.md`' "$commands_dir"/*.md || true
    } | sed -E 's/`references\/([^`]+\.md)`/\1/' | sort -u
  )
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
