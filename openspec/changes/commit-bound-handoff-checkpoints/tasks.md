## 1. 统一自动检查点边界

- [x] 1.1 修改 `handit/SKILL.md`：自动维护仅响应当前任务已观察到的有效成功 commit，移除实现、调查、失败、验证、阻塞、下一步变化和回复结束等触发；无明确活跃 handoff 不初始化或扫描。
- [x] 1.2 在入口及 `handoff-formats.md` 中定义可选 `checkpoint_commit` 和一次提交一次写回：重复 SHA 跳过，失败提交不触发，有效 amend 使用新 SHA，手动同步不伪造提交关联。
- [x] 1.3 在 `write-safety.md` 及相关入口统一 handoff-only 提交不触发、维护不催促或创建提交、不 stage/amend/push、不轮询或追补外部提交的边界。
- [x] 1.4 收窄 `artifact-lifecycle.md` 的维护时机：已有记录规则仅在获准写回时执行，不在执行步骤之间检查淘汰，不为完善记录扩展调查、测试或历史读取。

## 2. 移除下一步维护并统一命令

- [x] 2.1 更新 light/full 模板为 State、Blocked；移除索引 Next Action、Needed、Follow-up 等计划栏位，保留事实状态、正式任务引用及原有授权边界。
- [x] 2.2 更新 `tracehandoff.md`：显式同步仍可保存未提交事实，无变化不写；同步与自动检查点均不生成下一步、解决路线或逐 commit 日志。
- [x] 2.3 更新 `handoffprompt.md`：删除无条件“返回前写回”义务，接收者遵循相同 commit/显式同步边界；prompt 只引用已授权任务，不复制旧 Next 或生成额外待办。
- [x] 2.4 更新 `inithandoff.md`、`compacthandoff.md` 和相关归档/学习命令中的状态与索引约束，明确旧 Next 惰性忽略、显式迁移才移除，禁止换名保留下一步规划。
- [x] 2.5 检查 `task-specs.md` 与显式规划命令的边界：正式 task/spec 规划能力保留，不能把规划内容变成后台维护的 handoff 下一步。

## 3. 文档与回归场景

- [x] 3.1 更新 README、当前 light/full/绑定任务示例及两类 transfer prompt 示例，展示 commit 检查点和不含 Next 的事实状态；专门保留 legacy 输入用于兼容验证。
- [x] 3.2 更新 `validate-skill.ps1` 与 `validate-skill.sh`，替换旧的高频维护断言，增加当前模板和转交模板的行为边界检查，避免全仓禁词误伤正式计划与 legacy 输入。
- [x] 3.3 添加紧凑正反例：重新加入 Next、无条件返回前写回时必须失败；合法 legacy 输入、正式任务计划和手动同步规则必须通过。
- [x] 3.4 添加隔离 Git 场景验收说明，覆盖未提交的连续执行、成功/失败/重复/amend 提交、handoff-only 与混合提交、无活跃 handoff、手动同步、旧 Next 和写入失败。

## 4. 验证与交付

- [x] 4.1 运行 PowerShell 和 shell 两套 validator 及正反例，记录结果；若某个运行环境不可用，明确保留该项未验证状态。
- [x] 4.2 在隔离临时仓库进行场景实跑并记录工具轨迹，检查维护读写次数与是否产生额外规划；不访问生产项目或用户级安装副本，不把静态校验当作模型行为实证。
- [x] 4.3 审核当前模板、命令、引用、README 的一致性，确认没有维护触发旁路、隐含下一步字段或为交接新增提交的行为；运行 OpenSpec 严格校验并报告验证边界。

用户级 skill 安装、版本发布、业务项目旧 handoff 批量迁移及 Git 提交/推送不属于本实现清单的默认交付范围。
