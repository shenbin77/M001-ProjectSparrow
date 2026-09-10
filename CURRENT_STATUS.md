# CURRENT STATUS — 赤雀 / M001

更新时间：2026-09-11（Day2 上午，C2 闭环收尾）。主开发根目录 **D:\AI-Game-Factory\M001-ProjectSparrow**；资产根 **D:\AI-Game-Factory\assets**；仓库 **https://github.com/shenbin77/M001-ProjectSparrow**（public）。M001 ACTIVE；G002 PARKED/READY（GDD 存档于 docs/G002_PROJECT_LEGACY_GDD.md）。

## 原始目标 / 完成条件
2026-09-17 目标 Windows 可玩 RC、英语教程、完整 1–2 小时职业循环、存档/规则/崩溃回归、Steam 推进到平台允许最远状态。当前为 0.2.0-dev（C2 闭环全绿），不是 RC。

## 本轮（C2）完成
- **P0 修复**：start_match 曾把 tensei/pressure 塞进 ai_profile 触发 adapter 校验崩溃 → 风格改走 per-seat ai_profiles，ai_profile 恒 "rookie" 基座；回归测试锁定 4 风格请求形状。
- **俱乐部差异化 AI**：backend/club-styles.cjs（TenseiPlayer 学院派防守 / PressurePlayer 压迫派，继承 vendor ProfessionalPlayer，vendor 冻结零改动）；4 家俱乐部映射 rookie/tensei/pressure/professional。
- **剧情事件引擎**：career.gd event_snapshot()/choose_event()（at_match 触发 + events_seen 一次性 + 资金/士气/关系 delta），修掉 Story 标签页 P0 潜伏崩溃；18 条新断言。
- **技能目录麻将化**：skills.gd 增量 +5（仅 training_xp/economy 效果），旧 8 条与存档兼容；characters.json 加 play_style 字段。
- **存档健壮性**：load_from 对旧/残缺档仅补缺不覆盖（破损值仍 fail-closed）；main.gd 事件渲染 .get 加固。
- **资产批次 1**：15 张概念图（D盘根「Codex 图像 2026年9月11日 *.png」）按视觉识别重命名归档到 assets/{M001,G002,shared}；**复制/归档 15 张，哈希去重 0 张**；全部 CONCEPT_ONLY，**尚无最终母版**；缺 2 张（白鹤秘境_project_sparrow.png、雀影新手的华丽一击.png）待补生成。索引：docs/ASSET_INDEX.md（真相源）。
- **文档治理**：DO_NOT_DO.md、SCOPE_NOW_NEXT_FUTURE.md 新建；DECISIONS.md 追加 D011–D016。
- **质量门**：Critic 六维两轮（C2/REVIEW.md + C2 复验 REVIEW2.md）；全量回归绿（见下）。

## 测试 / 证据
- node：5 测试文件 18/18 通过（adapter、data、professional-ai、club-ai、skills-coverage）。
- Godot：test_career 47/0、test_progression 70/0、test_campaign 33/0；VERIFY.ps1 ALL_CHECKPOINT_TESTS_PASSED（含真实对局→奖励幂等→回俱乐部 smoke）。
- 1000 局 AI 跑测：pressure-1000 failures=0（mean 862ms，玩家胜率 20.3%）；tensei-1000 failures=0（mean 992ms，玩家胜率 20.3%）；work/playtest-*.json 留证。
- 未执行：干净 Windows 机器安装验证、1–2 小时真人试玩、正式导出模板打包（运行包仍用编辑器 exe）。

## 正在进行 / 下6小时
1. Godot 正式 Windows 导出模板打包 + 干净目录验证（RC 形态第一块）。
2. 教程/英语本地化收尾（Day5 项），批量 AI Playtest 扩 5000 种子。
3. 补 2 张缺失概念图（白鹤秘境/雀影新手）并走 IMPORT_ASSETS.ps1（已修 BOM+return 缺陷，PS5.1 解析通过）。
4. Steam 材料终稿（商店描述/截图清单/Trailer 脚本按 STEAM_RELEASE_CHECKLIST 勾选）。

## 阻塞 / 风险
- Steam AppID/付款/Coming Soon 日期为外部未知，最早公开发售日不可计算；仅授权动作等待用户，开发不暂停。
- 正式导出前 main.gd/career.gd 的 root_dir 依赖 editor-build globalize，非 editor 导出体下 data/backend 路径需干净目录验证（已列为 RC 前必做项）。
- 技能效果目前为局外成长/经济类（符合本周边界：不改牌山）；对手差异化已落地。

## 版本 / 提交
- 代码+文档里程碑提交 **SHA 2223c7d**（43 files，+3696/-170，已推 origin/main）。
- 资产图片随后独立提交（assets/ 批次 1，15 张）；.gitignore 排除 runtime exe / builds / work 日志 / node_modules。
- 许可证边界：vendor/majiang-core（MIT，冻结提交 7e96429）与 vendor/majiang-ai 保留各自 LICENSE；原创代码暂无对外许可声明。

## 回退
work/backups/checkpoint-02 含 C2 前脚本；C 盘旧目录保留迁移基线。不要删除个人存档或强制重置。
