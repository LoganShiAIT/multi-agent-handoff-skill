---
description: Create a personal HTML learning note from a task, knowledge point, reflection, or summary
argument-hint: "[task-slug | topic] [learning focus]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, LS
---

Use the `multi-agent-handoff` skill.

Create a personal learning note, not a team-facing report. The note can be based on a full handoff task, a knowledge point, a personal reflection, or a broader summary. The goal is to capture learning about engineering practice, design, debugging, review, operations, architecture, collaboration, or personal growth.

Task-linked study notes attach only to full handoffs. If the topic is a light handoff, create a standalone note only when the user explicitly asks; otherwise suggest keeping the learning in the light handoff's `Next` section or creating a full handoff first.

Do not force a fixed outline. Match the shape of the note to the case. It can read like a debugging case study, architecture reading guide, build-process reflection, proposal review, technology crash course, operational playbook, or personal "what I learned" essay.

Workflow:

1. Determine the study mode:
   - Task case: `$ARGUMENTS` names an active full handoff task.
   - Knowledge point: `$ARGUMENTS` names a concept, tool, API, pattern, or practice.
   - Personal reflection: `$ARGUMENTS` asks for感悟, 反思, 总结, or personal understanding.
   - Summary: `$ARGUMENTS` asks to consolidate several learnings.
2. If it is task-linked, read `HandoffDocs/handoff.md` and `HandoffDocs/handoffs/<task-slug>.md`. If ambiguous, list active full tasks and ask. Do not attach study notes to `HandoffDocs/light/`.
3. If it is standalone, use a kebab-case topic slug as `<study-scope>` and do not require a handoff file.
4. Inspect only the files needed to understand the learning. Do not read `archive/`, existing `study/` notes, or old artifacts unless the active handoff explicitly references them or the user asks for historical/learning material.
5. Treat old timestamped artifacts as potentially stale or orphaned. If used, label them as verified or unverified in the note.
6. Choose the output root:
   - Task-linked notes: `HandoffDocs/study/<task-slug>/`.
   - Standalone notes: use the project/user personal notes root if one is defined; otherwise use `HandoffDocs/study/<study-scope>/`.
7. Create `YYYYMMDD-HHMMSS-short-title.html` in the chosen output folder.
8. If task-linked, add the note path to the task handoff's `Study Notes` table. If standalone, just report the note path.

HTML note requirements:

- Write in Chinese by default.
- Keep it personal and reflective.
- Use a complete standalone HTML document.
- Include readable CSS in `<style>`.
- Avoid external assets or network dependencies.
- Do not paste long logs or raw outputs; summarize and link paths.
- Prefer concrete, case-specific headings over generic headings.
- Include tables, file trees, timelines, comparison blocks, warning boxes, checklists, or code snippets only when they help the learning.

Possible section patterns. Pick what fits; do not include all by default:

```html
<h1>短标题</h1>
<section>
  <h2>问题现场 / 项目定位 / 提案概述</h2>
  <p>先把真实上下文讲清楚。</p>
</section>
<section>
  <h2>关键概念解释 / 仓库结构 / 流程拆解</h2>
  <p>把理解这件事所需的背景补齐。</p>
</section>
<section>
  <h2>定位过程 / 关键决策 / 踩坑实录</h2>
  <p>写出为什么这样判断，而不只是写结果。</p>
</section>
<section>
  <h2>方法论沉淀 / 未来调试方法 / 回归清单</h2>
  <ul><li>把这次经验变成下次可复用的动作。</li></ul>
</section>
<section>
  <h2>核心反思 / 实习生带走 / 后续问题</h2>
  <p>写给未来自己的重点。</p>
</section>
```

End by reporting the created HTML path and the one most important lesson. Suggest `/tracehandoff <task-slug>` only if the note was task-linked and the handoff should record the learning; otherwise do not suggest extra commands.
