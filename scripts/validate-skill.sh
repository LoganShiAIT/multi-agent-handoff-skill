#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
skill_dir="$repo_root/multi-agent-handoff"
skill_file="$skill_dir/SKILL.md"
agent_file="$skill_dir/agents/openai.yaml"
commands_dir="$skill_dir/commands"
references_dir="$skill_dir/references"
readme_file="$repo_root/README.md"
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
  if ! grep -Eq -- "$pattern" "$path"; then
    errors+=("Missing $label")
  fi
}

require_not_grep() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if grep -Eqi -- "$pattern" "$path"; then
    errors+=("Found forbidden $label")
  fi
}

require_path "$skill_file" "SKILL.md"
require_path "$agent_file" "agents/openai.yaml"
require_path "$commands_dir" "commands directory"
require_path "$references_dir" "references directory"
require_path "$commands_dir/inittask.md" "inittask command"
require_path "$commands_dir/updatetask.md" "updatetask command"
require_path "$references_dir/task-specs.md" "task spec reference"

declared_commands=()
transition_command_pattern='explorehandoff|inittask|updatetask|inithandoff|tracehandoff|compacthandoff|handoffprompt|archivehandoff|study'
if [ -f "$skill_file" ]; then
  require_grep '^name:[[:space:]]*multi-agent-handoff[[:space:]]*$' "$skill_file" "SKILL.md name frontmatter"
  require_grep '^description:[[:space:]]*.+' "$skill_file" "SKILL.md description frontmatter"
  require_grep '^## Lazy Command Routing$' "$skill_file" "Lazy Command Routing"
  require_grep 'routine minimal handoff maintenance separate from command routing' "$skill_file" "routine maintenance boundary"
  require_not_grep 'After a handoff-related action.*suggest' "$skill_file" "global post-command suggestion rule"

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

if [ -f "$readme_file" ]; then
  require_grep '/inittask' "$readme_file" "README inittask command"
  require_grep '/updatetask' "$readme_file" "README updatetask command"
  require_grep 'external-first|外部规范优先' "$readme_file" "README external-first policy"
fi

if [ -f "$agent_file" ]; then
  require_not_grep 'default_prompt:.*(next agent|next session|handoff prompt|transfer prompt)' "$agent_file" "prompt-oriented default UI prompt"
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

    if [ "$command_name" != "handoffprompt.md" ]; then
      require_not_grep '(^|[^[:alnum:]_])/handoffprompt([^[:alnum:]_-]|$)' "$command_file" "$command_name handoffprompt reference"
    fi
    if [ "$command_name" != "explorehandoff.md" ]; then
      require_not_grep '(suggest|next-step hint|next useful command|natural-language alternative)' "$command_file" "$command_name optional command suggestion"
    fi

    source_command="${command_name%.md}"
    while IFS= read -r transition_line; do
      if grep -Eqi '(do not|never)[^.]*(suggest|recommend)' <<< "$transition_line"; then
        continue
      fi
      while IFS= read -r target_command; do
        [ -n "$target_command" ] || continue
        if [ "$source_command" != "explorehandoff" ] ||
           { [ "$target_command" != "inittask" ] && [ "$target_command" != "inithandoff" ]; }; then
          errors+=("Forbidden or cyclic command transition: $source_command -> $target_command")
        fi
      done < <(
        grep -Eo "/($transition_command_pattern)" <<< "$transition_line" |
          sed 's#^/##' |
          sort -u ||
          true
      )
    done < <(
      grep -Ei '(suggest|recommend|next[- ]?(step|command|action)|then[[:space:]]+(run|use)|follow[- ]?up)' "$command_file" ||
        true
    )
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
  "examples/task-spec-internal/HandoffDocs/tasks/add-session-timeout/task.md" \
  "examples/task-spec-internal/HandoffDocs/tasks/add-session-timeout/brief.md" \
  "examples/task-spec-internal/HandoffDocs/tasks/add-session-timeout/spec.md" \
  "examples/task-spec-internal/HandoffDocs/tasks/add-session-timeout/tasks.md" \
  "examples/task-spec-external/HandoffDocs/handoff.md" \
  "examples/task-spec-external/HandoffDocs/tasks/add-profile-filters/task.md" \
  "examples/task-spec-external/HandoffDocs/handoffs/add-profile-filters--w-01.md" \
  "examples/task-spec-external/openspec/changes/add-profile-filters/proposal.md" \
  "examples/task-spec-external/openspec/changes/add-profile-filters/specs/profile/spec.md" \
  "examples/task-spec-external/openspec/changes/add-profile-filters/tasks.md" \
  "examples/explore-output.md" \
  "examples/light-handoffprompt-output.md" \
  "examples/compact-history/HandoffDocs/artifacts/api-auth-investigation/reports/20260702-101500-compact-history.md" \
  "examples/handoffprompt-output.md"; do
  require_path "$repo_root/$example_path" "example $example_path"
done

if [ -f "$references_dir/handoff-formats.md" ]; then
  require_not_grep '^[[:space:]]*-[[:space:]]*(Handoff prompt|Prompt for the next agent):' "$references_dir/handoff-formats.md" "persistent prompt field in handoff formats"
  require_grep '^## Task Binding$' "$references_dir/handoff-formats.md" "Task Binding template section"
fi

for normal_handoff in \
  "$repo_root/examples/basic-handoff/HandoffDocs/handoffs/api-auth-investigation.md" \
  "$repo_root/examples/light-handoff/HandoffDocs/light/api-auth-investigation.md"; do
  if [ -f "$normal_handoff" ]; then
    require_not_grep '^[[:space:]]*-[[:space:]]*(Handoff prompt|Prompt for the next agent):' "$normal_handoff" "persistent prompt field in $(basename "$normal_handoff")"
  fi
done

if grep -Eriq -- '^[[:space:]]*-[[:space:]]*(Handoff prompt|Prompt for the next agent):' "$repo_root/examples"/*/HandoffDocs 2>/dev/null; then
  errors+=("Found forbidden persistent prompt field in HandoffDocs examples")
fi

if [ -f "$commands_dir/handoffprompt.md" ]; then
  require_grep '^## Manual Trigger Gate$' "$commands_dir/handoffprompt.md" "handoffprompt manual trigger gate"
  require_grep 'Do not create, save, cache, maintain' "$commands_dir/handoffprompt.md" "handoffprompt non-persistence rule"
  require_grep 'Do not copy proposal, spec, design, or work-item prose' "$commands_dir/handoffprompt.md" "handoffprompt path-only task binding"
  require_not_grep '(^|[^[:alnum:]_])/tracehandoff([^[:alnum:]_-]|$)' "$commands_dir/handoffprompt.md" "handoffprompt to tracehandoff edge"
fi

if [ -f "$commands_dir/tracehandoff.md" ]; then
  require_grep '^## Explicit Sync Boundary$' "$commands_dir/tracehandoff.md" "tracehandoff explicit sync boundary"
  require_grep 'Do not edit task specs, external spec artifacts, or task readiness' "$commands_dir/tracehandoff.md" "tracehandoff task-spec isolation"
fi

if [ -f "$commands_dir/inithandoff.md" ]; then
  require_grep '--from-task' "$commands_dir/inithandoff.md" "inithandoff task binding mode"
  require_grep 'Require task status `ready` or `in-progress`' "$commands_dir/inithandoff.md" "inithandoff ready gate"
fi

if [ -f "$commands_dir/compacthandoff.md" ]; then
  require_grep 'Preserve complete .*`Task Binding`' "$commands_dir/compacthandoff.md" "compaction Task Binding preservation"
fi

if [ -f "$commands_dir/archivehandoff.md" ]; then
  require_grep 'Do not move the task directory' "$commands_dir/archivehandoff.md" "archive task-spec independence"
fi

if [ -f "$references_dir/task-specs.md" ]; then
  require_grep '^## Source Selection$' "$references_dir/task-specs.md" "task spec source selection"
  require_grep '^## Task Record Template$' "$references_dir/task-specs.md" "task record template"
  require_grep 'draft[[:space:]]*\|[[:space:]]*ready[[:space:]]*\|[[:space:]]*in-progress[[:space:]]*\|[[:space:]]*blocked[[:space:]]*\|[[:space:]]*done' "$references_dir/task-specs.md" "task status lifecycle"
  require_grep 'explicit user confirmation' "$references_dir/task-specs.md" "explicit ready gate"
  require_grep 'If several external candidates are plausible, stop' "$references_dir/task-specs.md" "ambiguous external source stop rule"
  require_grep 'Allow task-bound execution only from `ready` or `in-progress`' "$references_dir/task-specs.md" "task-bound execution status gate"
fi

external_task_dir="$repo_root/examples/task-spec-external/HandoffDocs/tasks/add-profile-filters"
for forbidden_external_copy in brief.md spec.md design.md tasks.md; do
  if [ -e "$external_task_dir/$forbidden_external_copy" ]; then
    errors+=("External task example duplicates spec content: $external_task_dir/$forbidden_external_copy")
  fi
done

external_handoff="$repo_root/examples/task-spec-external/HandoffDocs/handoffs/add-profile-filters--w-01.md"
if [ -f "$external_handoff" ]; then
  require_grep '^## Task Binding$' "$external_handoff" "external example Task Binding"
fi

external_task_record="$external_task_dir/task.md"
if [ -f "$external_task_record" ]; then
  require_grep '^[[:space:]]*-[[:space:]]*Owner:[[:space:]]*external[[:space:]]*$' "$external_task_record" "external example owner"
fi

if [ "${#errors[@]}" -gt 0 ]; then
  printf 'Skill validation failed:\n' >&2
  for error in "${errors[@]}"; do
    printf ' - %s\n' "$error" >&2
  done
  exit 1
fi

printf 'Skill validation passed.\n'
