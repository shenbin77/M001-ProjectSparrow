# CURRENT STATUS — 赤雀 / M001

更新时间：2026-09-11，Day1。主开发根目录 **D:\AI-Game-Factory\M001-ProjectSparrow**。M001 ACTIVE；G002 PARKED/READY。

## 原始目标 / 完成条件
2026-09-17目标Windows可玩RC、英语教程、8角色占位视觉、3–4家对手俱乐部、完整1–2小时职业循环、存档/规则/崩溃回归与Steam允许范围内推进。当前仅0.1.0-dev首日开发检查点，不能称RC或Steam-ready。

## 已完成
- 八份正式项目文档全部落盘；开源报告核验12仓，G002完整冻结。
- 按用户要求迁至D盘，迁移时SHA256零差异；C盘旧目录保留回退。
- Godot4.6.1 + Node24.18.1本地运行；MIT majiang-core1.4.1冻结提交7e964296dd8eb5ff5a32f8182acdc6a0c2a81cbb，保留许可证。
- 可操作Godot单局Riichi，合法动作、AI自动完成、计分、公开弃牌/副露、终局奖励返回俱乐部。
- 8角色数据、4个挑战节点、招募、训练经验/等级、4技能配置槽、一次性剧情选择、局外存档/备份恢复。
- Windows JSON引号传参故障已修：临时JSON文件+异步子进程，15秒超时。
- 两轮独立Critic发现的问题已记录并修主要项；第二轮用OpenCode官方免费模型。
- 原生OpenGL窗口运行并保存club-preview.png/table-preview.png。
- m001每6小时续跑已更新为D盘路径，依赖本机与应用可用。

## 测试 / 证据
- 已执行通过：上游1,026 tests（C盘work/research/majiang-core研究环境）。
- 已执行通过：项目5组Node测试：50自动局及重演、30交互局涵盖吃碰杠、非法输入、角色数据。
- 已执行通过：Godot22项成长/存档检查（含覆盖/备份/损坏拒绝）。
- 已执行通过：Godot真实对局→奖励→返回俱乐部smoke、重复渲染不重复奖励。
- 最新综合命令 VERIFY.ps1，日志 work/verification-final.log。
- 首轮失败：GDScript推断类型、JSON argv、存档数值类型Roundtrip，已修并重跑。
- 未执行：干净Windows安装、1–2小时真人试玩、完整UI点击回归、断电存档测试、Steam提交。

## 正在进行 / 下6小时
1. OpenCode免费Worker优先做牌桌UX（少滚动、牌面辨识、禁重复点击）和规则教学，不生成角色图。
2. 补角色schema与技能真实作用（仅局外成长/训练；不得改牌山），俱乐部差异化AI；优先复用majiang-ai。
3. 完整局内状态/失败路径回归，处理国士抢暗杠等罕见Adapter边界，扩AI Playtest至1000种子。
4. Godot正式Windows导出模板打包，干净目录/机器验证；当前运行包仍用编辑器可执行文件。
5. Day2–3完成成长循环的可玩深度，再推进联赛、教程、本地化与Steam材料。

## Worker与额度
- OpenCode1.18.21实际可用，官方opencode/mimo-v2.5-free已完成2个任务：8角色JSON生成、只读代码审查。生成结构键players归一为characters后通过结构测试；首轮严格输出合同不算完美遵守。
- 2个Worker任务均交付可用产物，验收后采用2/2；探测失败另计，不伪装总可靠性。OpenCode两任务回报cost=0，此为工具报告，不是核实账单。
- 本地Qwen 8080 **未启动成功**；旧免费代理18906离线，探测失败1次。启动组合请求被策略拒绝，未绕过。
- Codex子代理已停止扩张；一个Critic遇额度限制，已由免费Worker接替。Codex本任务精确token/金额unknown。

## 阻塞 / 风险
技能目前只是配置数据，未改变玩法；挑战节点没有独立AI风格；尚非完整职业联赛。固定庄家单局不是半庄。种子重演不可用于公平联网。Steam AppID/授权/付款/Coming Soon日期未知，最早公开发售日不能计算；仅对应授权动作等待用户，其余开发不暂停。

## 回退
D盘work/backups/checkpoint-02含本轮前脚本；C盘原项目目录保存迁移基线。不要删除个人存档或执行强制重置。回退时先保留当前版本，复制所需文件并重新VERIFY。
