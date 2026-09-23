## Why

Handit 当前要求在实现、调查、失败、验证和下一步变化之后维护交接记录，使 agent 在执行中持续承担记录筛选、写回和历史整理工作，消耗 token 并分散对用户任务的注意力。与此同时，自动维护 `Next` 会引入额外规划推理，并可能把超出用户意图的建议固化为接手者的任务。

## What Changes

- **BREAKING** 将现有 handoff 的自动写回绑定到当前任务成功 commit：一次符合条件的提交对应至多一次集中写回，两次提交之间不自动维护；用户通过正常提交节奏控制频率。
- 保留用户明确要求同步或保存交接状态的手动入口；初始化、归档等显式命令仍按其授权范围执行。暂停、遇到阻塞、验证完成或结束回复本身不构成额外自动触发器。
- 禁止为 handoff 创建、催促或拆分提交；仅维护交接文件的提交不再次触发自动写回。
- **BREAKING** 从 light/full handoff、执行索引及转交模板中移除由 handoff 维护的 `Next`、`Next Action` 和同义后续计划字段。后续行动由用户指令或正式任务定义决定。
- 写回只整理已知事实、验证结论、已知未解决问题及明确约束；不生成执行路线，不为完善交接额外调查或重跑验证。
- 更新命令、示例、README 和两套校验脚本，防止“返回前更新”等旁路重新引入高频维护。

## Capabilities

### New Capabilities

- `handoff-checkpoint-trigger`: 定义 commit 驱动的自动检查点、显式同步、重复事件处理和无提交循环的行为契约。
- `factual-handoff-state`: 定义不含下一步规划的事实型交接格式、信息边界及旧字段兼容策略。

### Modified Capabilities

无。当前仓库尚无已建立的 OpenSpec 主规格；上述能力为现有 skill 行为首次建立规格。

## Impact

- 入口：`handit/SKILL.md`。
- 引用：`handoff-formats.md`、`artifact-lifecycle.md`、`write-safety.md`、`task-specs.md` 中的维护规则和跨文件约束。
- 命令：重点涉及 `tracehandoff`、`handoffprompt`、`inithandoff`、`compacthandoff` 及会重建索引或状态的相关命令。
- 文档与验证：README、light/full/legacy/转交示例、`scripts/validate-skill.ps1` 和 `scripts/validate-skill.sh`。
- 兼容性：旧 `Next` 可被识别但不作为行动授权，也不再刷新；显式迁移时移除旧字段，历史文件不批量重写。
- 本变更不增加 Git hook、后台服务、轮询、agent 委派或新运行时依赖；不重构记录淘汰算法、light/full 架构或正式 task-spec 规划能力。
- 当前交付仅为提案，不修改运行中的 skill、用户级安装目录、业务仓库 handoff 或 Git 提交状态。
