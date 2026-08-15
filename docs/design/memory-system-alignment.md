# 借鉴记忆系统：设计记录

状态：**部分落地，其余搁置**。第 1、2、3 点已实现；第 4、5、6 点仅有设计，未动手。

这份文档保留这一轮的完整推理链，包括被撤销的方案和撤销的原因，目的是让后续接手时不必重新推导，也不会重复走一遍已经否掉的路。

## 背景

起点是一个问题：handit 记录 log 和项目进度的文件结构，能从 Claude 的记忆系统借鉴什么。

两套系统解决的是同一个问题——**在有限上下文里只保留还会改变下一步行为的事实**——但结构不同。

记忆系统：

- 索引 `MEMORY.md`，每条记忆一行
- 小文件 = **一条事实**，文件名即 ID，frontmatter 带 `type` 和 `description`

handit：

- 索引 `HandoffDocs/handoff.md`
- 小文件 = **一个执行槽**，槽内 `## Log` 还装着 N 条事实

两边都是「索引 + 每项一个小文件」，差别在**原子单位落在哪一层**。记忆系统的一条事实恰好是一个文件，因此白拿了文件系统给的三样东西：文件名当 ID、frontmatter 装类型、frontmatter 装摘要。handit 的一条事实是文件里的一行 bullet，这三样一样都没有。

这个三层结构本身是对的，不该拍平成记忆系统那样：同一槽内的记录共享 `Scope` 和 `Context`，拆成独立文件反而离散。结论是——既然事实住在没有元数据槽的那一层，元数据就得显式写进那一行。

反向也成立，有两处 handit 领先，**不要照抄记忆系统**：

- 记忆系统的淘汰规则只有一句「delete memories that turn out to be wrong」。handit 的 superseded / landed / resolved 三个客观状态测试更强。
- 「10 条活记录 = 范围报警，而不是压缩触发器」在记忆系统里没有对应物。
- 记忆系统无确认直接写，handit 全程有确认门。域不同，确认门要保留。

## 已落地

### 第 1、2 点：记录带编号和类型

两点共用一个格式改动：

```markdown
- [R-02 rejected] 2026-08-03 否决了基于数量的自动压缩，因为数量把体量和过期混为一谈。
```

**类型**解决的是一处自相矛盾。`handoff-formats.md` 规定 `Log` 只收四类事实，`artifact-lifecycle.md` 又规定前三类永不淘汰——但记录本身不写自己是哪一类，后来的 agent 必须读懂中文散文再自行归类才能决定能不能删。而「让 agent 自行判断」正是 `handoff-structure-redesign` 这个槽当初明确否掉的做法（主观、跨会话不稳定、由记录作者自评、不可审计）。它在「重要性」维度被消灭，却从「类型」维度溜了回来。

因此在 `artifact-lifecycle.md` 增加类型到死因的查表：

| 类型 | 何时死亡 |
| --- | --- |
| `decision` | 被取代，或已落地进代码/配置/规范 |
| `blocker` | 被取代，或已解决 |
| `failed` | 永不 |
| `rejected` | 永不 |

这张表**没有引入新政策**，只是把原有的「Never evict failed attempts, rejected alternatives, or unresolved blockers」显式化。它顺带说清一件原本隐含的事：`landed` 只可能作用于 `decision`，这正是「成功的工作自己过期、失败不会」的机制所在。

**编号**解决的是记录没有身份。原来的记录是匿名 bullet，后果在实际文件里可见：`artifacts/<slug>/history.md` 只能把被淘汰记录的整段原文抄一遍，因为没有 key 能指回去；跨槽引用只能复制粘贴，副本不会跟着正本更新。

编号在槽位内从 `R-01` 递增，**淘汰后不回收**——否则 `history.md` 里的 `R-04` 会指向两条不同的记录。

改动落点：`handoff-formats.md` 的 `### Log` 与两个模板、`artifact-lifecycle.md` 的 `Record Lifecycle`、`SKILL.md` 的日常维护段、`tracehandoff.md` 的追加与淘汰步骤、`compacthandoff.md` 的保留与旧格式迁移步骤。

旧格式迁移特别加了一条：旧 `Progress Log` 里如果是纯事件、背后没有失败/否决/阻塞/决策，**直接丢弃，不要硬编一个类型**。

### 第 3 点：索引行是指针不是摘要

`handoff-formats.md` 新增 `### Rows Are Pointers`。

判据不是字数，而是**这一格有没有独立的真值条件**。字数规则与正确性无关：30 词的纯指针没问题，12 词的复述照样漂移，agent 也无法据此推理。

- `blocked on schema decision` —— 没有自己的事实，它描述的状态就在链接文件里，不能单独变错。
- 一整段复述「发现了什么、怎么修的、验证了什么」—— 含多条各自能独立变假的断言，且没有任何机制会发现。

可执行的检查：数这格里有几条能单独变假的断言。零条是指针，一条以上是副本。

受影响的六列不是挑出来的，是筛出来的。`Slug` 是标识符，`Owner`/`Status`/`Updated`/`Archived At` 从 frontmatter 生成或本身是日期，`Replacement` 是链接——都没有独立真值。剩下 `Next Action`、`Blocker`、`Needed`、`Result`、`Follow-up`、`Reason` 六列，**每一列的内容在别处都已有完整的一份**。

`/compacthandoff` 的索引压缩原来只收前三列（即只管 `Active` 和 `Blocked`）。漂移最严重的恰恰是没管的后三列：

1. `Done` / `Archived` 的行写完再没人碰。活跃行每次状态变化都被重看一遍，已完成的行是一次性写入。
2. 它们链接的文件在 `archive/` 下，而 `artifact-lifecycle.md` 明确把 archive 排除在默认操作上下文之外。**没人会去读正本来发现副本已经不对了。**

唯一会被读到的是可能已经错了的副本，正本被规则挡在视线外——最坏的组合。因此扩到六列。

同时补了一句「Shortening a cell is not dropping a row」。因为这条命令周围全是硬禁令（不许删未解决阻塞、风险、待确认项、清理候选、artifact 路径、`Extra Files` 行），agent 读到「把 `Follow-up` 收短」紧挨这些禁令很可能不敢动。那句话消歧义：行还在，链接还在，只是散文变短。

### 验证器

`validate-skill.sh` 和 `validate-skill.ps1` 各加 4 条守卫：两个模板的记录必须带 ID 和类型、`handoff-formats.md` 必须保留编号不回收规则与 `Rows Are Pointers` 段、`artifact-lifecycle.md` 必须保留类型死因表的四行与 ID 退休规则。

另外在已有的示例遍历循环里加了一条：示例里不允许出现无标签的 `- YYYY-MM-DD` 记录。这条做过反向测试——手动去掉标签则验证失败，还原则通过。

PowerShell 版本本机无法执行（`pwsh` 未安装且当时拒绝安装），依赖 CI 的 Windows job 首次实跑。

## 撤销了什么，为什么

原计划的「第 4 点」是让 `light/` 和 `tasks/` 变得可发现，已经动手改了 `handoff-formats.md`、`inithandoff.md`、`task-specs.md`，**随后全部撤销**。

撤销原因：这一点把两件不同的事捆在了一起。

**light 笔记**：完全没有任何发现路径。不绑 task、不进索引、没有任何文件引用它，除了 `ls light/` 没有第二种知道它存在的办法。`light/` 100% 是 handit 自有，没有归属争议。这是纯缺口。

**task 记录**：有部分发现路径。执行一旦开始，`handoffs/<slug>.md` 的 frontmatter `task:` 字段指回来，`task.md` 的 `Execution Bindings` 表也在。但 `draft` 和 `ready` 状态、尚未开始执行的 task，确实谁都不指向。

更重要的是 task 层牵扯到与 spec 工作流的配合。外部规范模式下 `tasks/<slug>/task.md` 只是绑定记录，真正的 owner 是 OpenSpec / OPSX，而外部工作流自己就有清单。索引里再加一列 `Status`，链路会变成三跳：

```text
外部工作流的真实状态  →  task.md 的 Status  →  索引行的 Status
```

每一跳都是手工维护的副本——正是第 3 点批评的漂移问题，只是换了个方向。

（需要说准确：`task.md` 自己存 Status 是合理的，那是 handit 的协调状态，不是外部内容的镜像。问题不是「不该存」，而是「要不要存第三份」。）

结论：light 那一半没有争议，可以单独做；task 那一半必须先想清楚与 spec 工作流的边界，不能顺手带过。

## 未决问题

### 一、四种类型可能不够

改示例时撞上的：`examples/basic-handoff` 那条记录是「原因是 retry 复用了旧 header，不是 provider 端过期」——这是一条**调查结论**，四种类型里没有精确对应的。

暂时标为 `decision`，理由是它排除了 provider 配置这条路、后续不该悄悄推翻，生命周期也与 decision 一致（测试把结论钉死时即 landed）。

如果认为调查结论应有自己的类型（如 `finding`），那是加第五种，属于扩政策，未擅自决定。

### 二、实际索引的收窄被信息安全挡住

`HandoffDocs/handoff.md` 里 `review-entire-skill` 那格 `Reason` 按第 3 点该收成一句话。但核对过 `archive/2026-08/review-entire-skill.md`——里面只有当初的三条 P1/P2 发现，**没有**「follow-up 已于 2026-08-03 验证关闭、三条分别怎么修的」这段。

索引那格是**唯一副本**，直接收短即销毁信息。正确顺序是先把这段补进归档文件，再收索引。未执行。

（这也反过来说明：第 3 点的规则需要配一条前置检查——收窄一格之前，先确认它的内容在链接文件里确实存在。这条目前没写进 `handoff-formats.md`，值得补。）

### 三、light 的可发现性

见上节。方案已经想清楚，只差与 task 层的边界决策：

- 给 `handoff.md` 加一张只有 slug / status / updated 三列的 `Light` 表；
- `handoff.md` 的定义从「full execution index only」改为「索引本根下的所有状态」；
- 该表在写入第一行时才创建，为空则不存在（与既有的「不预置空段、不预建空目录」惯例一致）；
- light 模式因此**可以**创建索引——只写自己那一行，仍然不创建 task 绑定、artifacts、archive、study 状态。原禁令针对的是拖入完整协调机制，写一行目录不属于此。

## 还没做的

原分析共 6 点，落地 3 点。剩下三点按价值排序：

### 第 4 点：frontmatter 缺一句话摘要

记忆系统的 `description` 存在的唯一理由是让召回不打开文件就能判断相关性。handit 的 frontmatter（slug / status / owner / updated / branch / task / work_item）全是机器状态，没有一个字段回答「这个槽是关于什么的」。`handoffs/` 堆到八个文件时只能靠 slug 猜。

加一行 `description:` 即可，顺带让索引行真正可生成（与第 3 点相互支撑）。

### 第 5 点：淘汰只在写入时触发，缺独立复审

`artifact-lifecycle.md` 规定每次写 `Log` 时检查新记录杀死了哪些旧记录。漏洞在于：如果这个槽之后再没写过新记录，一条早已 landed 的决策会永远躺在活跃区。「增量淘汰是主要长度控制」这个说法在这种情况下不成立。

`/compacthandoff` 不算对应物——它的定位是**长度**兜底（命令文件首段明写 "fallback, not the primary length control"），不是**正确性**扫描。

记忆系统的对应物是 `consolidate-memory`：一个独立于写入路径的反思扫描。handit 需要的是一个 audit 模式，不依赖新记录，把每条活记录重新过一遍三个状态测试。

### 第 6 点：模板说「一行」，实践需要「论断 + 理由」

记忆系统对 feedback / project 类型强制要求 `**Why:**` 和 `**How to apply:**`——事实不带可操作性就不存。

`handoff-formats.md` 写的是 "One line per record"，但实际产出的高价值记录（如本仓库 `handoff-structure-redesign` 槽内的两条 `rejected`）都是两三句，因为「否掉了 X」离开「因为 Y」就没有防止重蹈覆辙的能力。

建议把约束从长度改成形状：论断 + 为什么 + 后续不能反转什么。

## 本地状态说明

`HandoffDocs/` 与 `Logan的文档/` 都在 `.gitignore` 中，因此以下改动**只存在于本地工作副本，不在本分支内**：

- `HandoffDocs/handoffs/handoff-structure-redesign.md`：三条记录已补编号与类型（`R-02 decision`、`R-03 rejected`、`R-04 rejected`），`History` 表 `Covered` 格改为填 ID。
- `HandoffDocs/artifacts/handoff-structure-redesign/history.md`：新增 ID 列，被淘汰的 PowerShell 记录定为 `R-01`（类型 `blocker`，死因 resolved）。`R-01` 因此不会被重新发放。
- `HandoffDocs/handoff.md`：**未改动**，原因见未决问题二。
- `HandoffDocs/handoffs/deploy-codex-claude.md`：仍是旧结构（`Metadata` / `Mission` / `Context Packet` / `Progress Log` / `Findings and Decisions` / `Handoff Back`），未迁移。迁移是 `/compacthandoff` 的职责，本轮未触碰。
