<p align="center">
  <img src="assets/hero.svg" alt="Multi-Agent Handoff 产品横幅" width="100%">
</p>

<h1 align="center">Multi-Agent Handoff</h1>

<p align="center">
  面向 Claude Code、Codex 和手动启动的 Agent 会话的项目级交接协议。
  <br>
  按任务拆分上下文，让并行 Agent 可追踪、可接续，并避免过期笔记污染新工作。
</p>

<p align="center">
  <a href="#为什么需要它">为什么需要它</a>
  ·
  <a href="#安装">安装</a>
  ·
  <a href="#工作流">工作流</a>
  ·
  <a href="#命令">命令</a>
  ·
  <a href="#文件结构">文件结构</a>
  ·
  <a href="#开源协议">开源协议</a>
</p>

---

## 为什么需要它

真实的 Agent 工作很少只有一条干净的会话线。你可能让一个会话排查测试失败，让另一个会话整理迁移方案，再让第三个会话准备交给下一位 Agent 的提示词。所有内容都塞进一个巨大的 `HANDOFF.md`，很快就会变成多个会话共同编辑的上下文泥潭。

`multi-agent-handoff` 用一个紧凑索引，加上每个任务一份独立 handoff 文件，来管理手动多 Agent 协作：

- 每个任务都有自己的聚焦上下文；
- 每个任务 slot 都有一个 `Context Panel`，说明这个 slot 讨论什么、必须读哪些文件，以及哪些旧上下文不要默认读取；
- 每个 Agent 只更新自己的任务文件和索引行；
- 报告、测试输出、临时脚本、截图等过程产物放到可预测的位置；
- 归档、学习笔记和旧时间戳产物默认不作为当前上下文读取；
- 移动、删除、归档、修改 git 元数据等高风险操作必须先确认。

它不是复杂平台，而是一套足够无聊、足够稳定的多 Agent 项目协作操作系统。

## 安装

克隆仓库，然后把 skill 文件夹链接或复制到你使用的 Agent 环境中：

```bash
git clone https://github.com/LoganShiAIT/multi-agent-handoff-skill.git
cd multi-agent-handoff-skill

mkdir -p ~/.agents/skills ~/.codex/prompts ~/.claude/skills ~/.claude/commands
ln -sfn "$PWD/multi-agent-handoff" ~/.agents/skills/multi-agent-handoff
for d in "$PWD"/codex-slash-skills/*; do ln -sfn "$d" ~/.agents/skills/"$(basename "$d")"; done
ln -sfn "$PWD/multi-agent-handoff" ~/.claude/skills/multi-agent-handoff
ln -sf "$PWD/multi-agent-handoff"/commands/*.md ~/.codex/prompts/
ln -sf "$PWD/multi-agent-handoff"/commands/*.md ~/.claude/commands/
```

Codex 从 `~/.agents/skills/` 读取用户级 skills；`codex-slash-skills/` 是本仓库正式维护的一组轻量 wrapper skills，用来让 Codex app 的 slash 菜单出现 `/inithandoff`、`/tracehandoff`、`/handoffprompt`、`/archivehandoff`、`/study` 这类入口。`~/.codex/prompts/` 下的 Markdown 是 Codex CLI/IDE 的 deprecated custom prompts，调用形式是 `/prompts:<name>`。Claude Code 从 `~/.claude/skills/` 读取 skill，并从 `~/.claude/commands/` 读取 slash commands。

安装后重启 Codex 或 Claude Code。Codex app 中可以输入 `/inithandoff` 这类 wrapper skill，也可以用 `$multi-agent-handoff` 显式触发主 skill；Codex CLI/IDE 中可以用 `/prompts:inithandoff`、`/prompts:tracehandoff` 等命令调用辅助提示。对于不能自动加载 skill 的工具，可以让 Agent 手动读取 [`multi-agent-handoff/SKILL.md`](multi-agent-handoff/SKILL.md)。

## 工作流

进入项目后，先初始化或选择一个任务 handoff。默认的项目内 handoff 根目录是 `HandoffDocs/`：

```text
HandoffDocs/
|-- handoff.md
|-- handoffs/
|   |-- api-auth-investigation.md
|   `-- frontend-table-refactor.md
|-- archive/
|-- study/
`-- artifacts/
    `-- api-auth-investigation/
        |-- reports/
        |-- test-scripts/
        |-- test-results/
        `-- misc/
```

`handoff.md` 是项目仪表盘，只存放 active、blocked、done、archived 等任务行。详细上下文放在 `handoffs/<task-slug>.md`。

每个任务 handoff 记录：

- 任务目标、范围和成功标准；
- `Context Panel`：这个 slot 讨论的对象、必须读取的文件、必要时才读取的文件，以及默认不要读取的上下文；
- 已查看的文件和已经运行过的命令；
- OpenSpec 工作流状态：默认 `Spec Root` 为 `openspec/`，并记录当前是否 `not-needed`、`initialized`、`active`、`blocked` 或 `done`；
- 进度日志和关键决策；
- 相关产物路径；
- 在受控 artifacts 目录之外创建的额外临时文件；
- 交还给下一位 Agent 的当前状态、下一步和风险。

如果任务需要 OpenSpec change/spec，handoff 只记录引用和下一步；OpenSpec 自己的文件仍保留在 `openspec/` 工作流目录中，不移动到 `HandoffDocs/`。

`Context Panel` 是每个 slot 的缩影页。继续任务的 Agent 应先读它，再按其中列出的必读文件扩展上下文；不要因为同一个项目里有其他 handoff、归档、学习笔记或历史 artifacts，就默认把它们全部读进来。

`study/` 是独立的个人学习区，只用来沉淀新知、案例复盘或个人反思。它不改变 active / blocked / done / archived 这些任务看板，也不作为任务状态、归档状态或交接路线的事实源。

## 命令

内置命令是工作流关口。它们不替代判断，只是把关键时刻显式化。

| 命令 | 用途 |
| --- | --- |
| `/inithandoff` | 快速了解项目，创建或选择 `HandoffDocs/`，并建立带 OpenSpec 状态的当前任务上下文。 |
| `/tracehandoff` | 追加进度、阻塞点、验证结果和下一步。 |
| `/handoffprompt` | 为另一个 Agent 或新会话生成可直接粘贴的提示词包。 |
| `/archivehandoff` | 审计任务、分类产物，并准备需要用户确认的归档动作。 |
| `/study` | 把任务案例、知识点或个人反思整理成独立 HTML 学习笔记，不影响任务看板。 |

## 并行冲突控制

并行 Agent 只有在上下文不互相踩踏时才有价值。

`multi-agent-handoff` 的所有权规则很简单：

- 一个 Agent 级任务对应一个 task slug；
- 一个任务对应一个 handoff 文件；
- 一个任务 handoff 必须维护自己的 `Context Panel`，把讨论主题和文件边界说清楚；
- 一个任务只占用索引里的一行；
- 对共享索引只做最小局部编辑；
- 不读取 `archive/`、`study/` 或历史 artifacts，除非当前 handoff 或用户明确指向某个文件。

如果两个 Agent 需要处理同一批文件或同一块领域，要么合并为一个任务 owner，要么把依赖关系写进双方的任务 handoff。

## 安全模型

这个 skill 对文件操作保持保守：

- 正常工作中可以创建和更新 handoff 文件；
- 把任务移动到 `archive/` 前必须获得确认；
- 移动、删除或重新安置 artifacts 前必须获得确认；
- 修改 `.gitignore`、`.git/info/exclude`、暂存、提交和推送前必须获得确认；
- 旧时间戳产物在验证前都视为可能过期的候选上下文。

这样可以让 handoff 文档持续有用，同时避免它们悄悄改写工作区状态。

## 文件结构

```text
.
|-- README.md
|-- LICENSE
|-- .gitattributes
|-- assets/
|   `-- hero.svg
|-- multi-agent-handoff/
|   |-- SKILL.md
|   |-- agents/
|   |   `-- openai.yaml
|   `-- commands/
|       |-- archivehandoff.md
|       |-- handoffprompt.md
|       |-- inithandoff.md
|       |-- study.md
|       `-- tracehandoff.md
|-- codex-slash-skills/
|   |-- archivehandoff/
|   |-- handoffprompt/
|   |-- inithandoff/
|   |-- study/
|   `-- tracehandoff/
```

## 设计原则

- **索引，不堆日志。** 仪表盘保持短小、可操作。
- **任务上下文归任务文件。** 每个 Agent 级任务拥有自己的 handoff。
- **过程产物必须有归处。** 报告、输出、临时脚本和调试笔记不要散落在项目根。
- **旧上下文默认可疑。** 时间戳产物可以提供线索，但不能自动成为当前事实。
- **清理动作先确认。** 标记为候选移动或候选删除，不等于获得执行许可。

## 开源协议

本项目采用 [MIT License](LICENSE)。

选择 MIT 的原因很直接：`multi-agent-handoff` 是一个可复用的 agent skill/template，目标是方便个人、团队和商业项目低摩擦复制、改造、分发和二次集成。MIT 足够简洁，也不会给使用方引入额外的复杂合规负担。
