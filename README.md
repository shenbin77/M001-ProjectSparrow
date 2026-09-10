# Crimson Sparrow / 赤雀 — 0.1.0-dev

这是2026-09-11的首个Windows开发检查点，**不是Release Candidate**。

## 运行
双击 PLAY.cmd。已附Godot4.6.1与Node24.18.1运行时，不要求另行安装。仅离线单人。当前包使用Godot编辑器可执行文件以项目模式运行，不是优化后的正式导出模板构建。

开局挑战Dockside，点合法弃牌/鸣牌动作，或用AI finish自动打完一局。结算后回俱乐部训练、招募、配置四个技能槽。声望解锁更多挑战节点。存档只能局外操作；坏档可显式恢复.bak。关闭游戏前手动保存。默认存档位于Godot用户数据目录，卸载游戏目录不删除个人存档。

## 真实已实现
- MIT majiang-core完整规则引擎承载单局Riichi挑战：合法动作、AI弃牌、和牌计分、牌河和公开副露。
- 原创8人数据（OpenCode免费Worker生成后结构归一化），无正式人物美术。
- 资金、声望、一次性比赛奖励、招募、经验等级、可替换四技能槽、一次性剧情选择、校验存档和备份恢复。
- Godot到Node文件协议，15秒超时；不监听网络端口。

## 明确未完成
技能实际效果、不同对手策略/难度、完整赛季/联赛、1–2小时职业内容、完整规则教学、本地化切换、球探十连、局中存档、退役传承、Steam后台提交、干净Windows机器验证。技能配置目前只存数据，不影响牌局。各俱乐部当前是解锁节点，不应当作已经完成的联赛。联网和真钱抽卡不在本周Scope。

## 文档入口
CURRENT_STATUS.md → docs/00_MASTER_VISION.md → M001 GDD → 7_DAY_SPRINT_PLAN.md → ARCHITECTURE.md → DECISIONS.md。G002 GDD仅存档。

主开发位置 D:\AI-Game-Factory\M001-ProjectSparrow。C盘旧工程仅保留回退/交付副本，不双线修改。每6小时续跑依赖主机与Codex应用可用。

## 验证
运行 VERIFY.ps1。上游1,026测试已在独立研究目录跑通；本包测试包括4组适配测试（50自动局+30交互局），22项成长/存档检查，Godot完整闭环smoke。测试失败应返回非零；正式RC仍须单独验收。

## 许可证
vendor/majiang-core/LICENSE；runtime/NODE_LICENSE.txt；runtime/GODOT_LICENSE.txt。本项目原创代码暂未对外开放许可。不得把第三方MIT许可误认为项目所有原创IP均MIT。Godot第三方声明见runtime/GODOT_COPYRIGHT.txt。
