# OPEN SOURCE REUSE REPORT — M001 Project Sparrow

核验日期：2026-09-11。角色：独立 Research / Critic；本报告不替代主任务实际集成测试及最终 Release Gate。

## 结论与范围

**立即采用 majiang-core 原始 JavaScript 实现，Godot 只做 JSON Adapter 与表现层；不把麻将规则重写为 GDScript。** majiang-ai 可在同一 Node sidecar 中补入。先保留离线单人路径，不为了联网或“工厂”引入服务端。角色美术不在复用范围，所有形象仍用原创色块/几何占位。

下表的“节省”是工程估计，不是实测；单位为熟悉该栈的一人工作日，不能相加当排期承诺。“可直接复用”仅表示源码功能和许可证筛选适合，不表示已经集成通过。许可证为 GitHub 官方 API 的 SPDX 识别；最终纳入包仍须检查锁定提交的完整 LICENSE、第三方资产及传递依赖。许可证兼容不等于对全部专利、商标或资产给出法律保证。

## 模块选型表

| 模块 | 候选与决定 | 语言 / 依赖与适配 | 测试证据 / 未验证项 | 估计节时 |
|---|---|---|---|---|
| 标准日麻规则、局推进、牌墙、牌河 | [kobalab/majiang-core](https://github.com/kobalab/majiang-core)，MIT；**需要适配，首选** | JS 1.4.1；package.json 无 runtime dependencies；开发依赖 Mocha/nyc。原库 Game 驱动完整事件，不只调用计分函数；Godot UI 不得自行另维护规则真相 | test/game.js、test/board.js、test/he.js 及规则 fixture 已发现；本研究未运行其测试、覆盖率未知 | 15–30 日；Adapter 预计 0.5–2 日 |
| 和牌、向听、听牌、计分 | majiang-core Util，**可直接复用于 sidecar** | 与规则核心同版本，避免不同库的赤牌/食断/役满规则参数冲突 | test/hule.js 与 test/data/hule.json、xiangting 数据已发现；尚须检查符、振听、无役、流局、立直、杠、宝牌边界 | 5–15 日，已包含于上行 |
| 独立计分交叉校验 | [MahjongRepository/mahjong](https://github.com/MahjongRepository/mahjong)，MIT；**需要适配，仅测试参考候选** | Python >=3.10，当前 pyproject version 2.0.0，无 project runtime dependencies 声明；pytest/pytest-cov 为开发依赖。不要让发行包同时依赖 Node 与 Python | tests/hand_calculating 与 CI 存在；配置 fail_under=100 是门槛，不是本次测得 100%；本次未运行 | 2–5 日验证工作 |
| 麻将 AI | [kobalab/majiang-ai](https://github.com/kobalab/majiang-ai)，MIT；**需要适配，优先** | JS 1.2.0；依赖 @kobalab/majiang-core ^1.3.4，和锁定 1.4.1 的兼容性需要回归；同 Node 进程避免第二通信层 | test/player.js、test/suanpai.js、test/minipaipu.js 存在，Mocha/nyc；没有本次强度、耗时与公平性实测 | 5–15 日 |
| Godot 引擎、UI、文件 API、基础网络 | [godotengine/godot](https://github.com/godotengine/godot)，MIT；**可直接复用稳定发行版** | C++ 引擎 / GDScript 游戏；Control/Container/Theme、JSON、FileAccess、原生 Multiplayer/ENet。仓库 HEAD 仅用于活跃度，不指定追随开发分支 | 上游 tests 与多平台 CI 存在；实际选定本机二进制版本、Windows export template 必须由主任务记录并实测 | UI 基础 2–5 日 |
| Godot 麻将/卡牌现成 UI | [db0/godot-card-game-framework](https://github.com/db0/godot-card-game-framework)，**AGPL-3.0，不建议/禁止直接合入** | GDScript 卡牌框架，非日麻规则引擎；不复制代码、UI 资产或测试文件 | tests 与 GUT 路径存在，不改变许可证排除结论；具体引擎适配未核验 | 本周 0 日；避开许可和改造风险 |
| 对话/剧情系统 | [nathanhoad/godot_dialogue_manager](https://github.com/nathanhoad/godot_dialogue_manager)，MIT；**需要适配，Day 3 候选** | GDScript Godot 插件，先锁定与实际 Godot 小版本兼容的 tag；剧情 choices 通过受控命令写经营状态，不能直接重复发奖励 | tests/test.gd、state_for_tests.gd 及 dialogue fixture 存在；未运行、覆盖率未知 | 2–4 日 |
| RPG 数据编辑层 | [bitbrain/pandora](https://github.com/bitbrain/pandora)，MIT；**不建议本周引入** | GDScript 数据编辑插件；上游 README 明示 ALPHA / NOT PRODUCTION-READY。先使用 Godot JSON + schemaVersion + 稳定实体 ID | test/api_test.gd、test/backend/ 与 CI 存在；不等于成熟可发布；随仓 gdUnit4 仍需第三方清单 | 本周净节时不确定，记 0 |
| 存档/状态机 | [limbonaut/limboai](https://github.com/limbonaut/limboai)，MIT；**状态机需要适配但本周不引入**；存档采用 Godot 原生 API | LimboAI C++ GDExtension / behavior tree / HSM 增加二进制版本配对。M001 只需要少量显式状态、原子写入、backup、迁移函数；不需要行为树框架 | 上游 test_builds.yml 存在；本次没有功能覆盖率与 DLL 兼容实测。自身存档要做截断/坏 JSON/旧 schema/重复结算测试 | 本周净节时不确定，记 0 |
| 联赛、排名、经营数据层 | Godot 原生 JSON / Resource，**自研最小业务层**；Nakama leaderboard 为未来候选 | 本地赛事晋级、角色训练和经济规则是产品特定数据，不复制在线排行榜作为赛季规则；稳定 IDs，结算唯一 match ID；Pandora 未达当前风险门槛 | 必须自测积分同分排序、晋级边界、资金不负、奖励幂等、save/load；当前为验收要求而非已通过 | 0；预计实现 0.5–1.5 日 |
| Steamworks 封装 | [GodotSteam/GodotSteam](https://github.com/GodotSteam/GodotSteam)，**当前 GitHub 源不建议直接引入** | 官方 GitHub 已 archived，LICENSE=null，README 指向 [Codeberg 新源](https://codeberg.org/godotsteam/godotsteam)。不能沿用旧记忆说当前源码已通过 MIT 审查。待新源 LICENSE、tag、Godot ABI、Steam SDK 分发条款核验 | GitHub 占位仓无测试证据；Codeberg 本轮未核验。Steam SDK/账号授权必须独立处理。离线 Windows build 不需先依赖插件 | 未来 1–3 日；本周未确认 |
| 多人、lobby、matchmaking、服务器排名 | [heroiclabs/nakama](https://github.com/heroiclabs/nakama) + [nakama-godot](https://github.com/heroiclabs/nakama-godot)，Apache-2.0；**需要适配，推迟** | Go 服务端、数据库和部署运维；GDScript SDK。server go.mod/vendor 有大量依赖须逐项再审；不要误报为零依赖。未来 Classic Ranked 必须 server authoritative，不允许客户端发牌决定结果 | server tests.yaml、SDK socket/client/retry_timeout 测试路径；未部署未运行，覆盖率未知 | 未来 10–25 日；本周 0 |
| Godot 自动测试 | [godot-gdunit-labs/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4)，MIT；**需要适配，优先候选** | 原 MikeSchulze/gdUnit4 已重定向；GDScript addon。必须按本机 Godot 版本锁兼容 release；Day 1 可先 headless SceneTree/assert 和 Node 内建测试建立可运行基线 | addons/gdUnit4/test 与 CI 存在；本轮未装/未执行；覆盖率未知 | 2–4 日 |

## 锁定源与可追溯事实

下面来自 GitHub API /repos、/commits?per_page=1、递归 tree。push 时间并不等于默认分支 commit 时间，也不代表维护者承诺。未归档仅是当前状态，不能当成维护质量评分。全部未执行依赖安装；未复制 AGPL 项目内容。
| Repo | 最后 push UTC | HEAD commit UTC | 锁定观察 SHA | LICENSE | archived |
|---|---|---|---|---|---|
| [kobalab/majiang-core](https://github.com/kobalab/majiang-core) | 04/12/2026 03:41:26 | 04/12/2026 03:41:06 | `7e964296dd8eb5ff5a32f8182acdc6a0c2a81cbb` | MIT | False |
| [kobalab/majiang-ai](https://github.com/kobalab/majiang-ai) | 08/15/2026 11:33:24 | 08/15/2026 11:31:54 | `e21ac9bdcb615857a7e3c8ae97e4357fc1452c7e` | MIT | False |
| [MahjongRepository/mahjong](https://github.com/MahjongRepository/mahjong) | 08/16/2026 11:27:10 | 06/15/2026 08:37:44 | `51675182ae0c040a4cb143eb1e109dc06e0a78b2` | MIT | False |
| [nathanhoad/godot_dialogue_manager](https://github.com/nathanhoad/godot_dialogue_manager) | 09/09/2026 08:25:35 | 09/09/2026 08:25:35 | `934ff537cee96e1484a2430066b685283999d40c` | MIT | False |
| [MikeSchulze/gdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) | 08/30/2026 15:24:53 | 08/30/2026 15:24:51 | `dba0b288d0e1b9a393c6edd05f9a340bbb9a275a` | MIT | False |
| [GodotSteam/GodotSteam](https://github.com/GodotSteam/GodotSteam) | 09/04/2026 01:33:29 | 09/22/2025 18:27:07 | `27d72b085d92cff26d5eaf740c9a69907abf5745` |  | True |
| [heroiclabs/nakama](https://github.com/heroiclabs/nakama) | 09/10/2026 17:31:49 | 09/10/2026 16:50:43 | `3c8401bcb67ee2b19a997f9220723edfa1d8cfa4` | Apache-2.0 | False |
| [heroiclabs/nakama-godot](https://github.com/heroiclabs/nakama-godot) | 08/11/2026 21:05:16 | 08/11/2026 15:10:01 | `7549fea8cb4d62a319028946de01a2993440c2d6` | Apache-2.0 | False |
| [bitbrain/pandora](https://github.com/bitbrain/pandora) | 08/20/2026 17:22:22 | 08/20/2026 17:22:15 | `fa48e30e6609ecd6dbd9edf25e0a26f64deb26a0` | MIT | False |
| [limbonaut/limboai](https://github.com/limbonaut/limboai) | 09/04/2026 17:28:25 | 09/04/2026 17:28:24 | `3f14ea4c26911e8b8e30c6bcdb575fc589a59deb` | MIT | False |
| [godotengine/godot](https://github.com/godotengine/godot) | 09/09/2026 19:59:14 | 09/09/2026 19:36:26 | `4cefd60f5a3d733506cb557d6cd26263b3fbd17f` | MIT | False |
| [db0/godot-card-game-framework](https://github.com/db0/godot-card-game-framework) | 05/20/2025 11:42:56 | 05/20/2025 11:42:56 | `f3ca9afd9705ff895839253fad208360d2f45146` | AGPL-3.0 | False |

## 独立 Critic：Adapter 风险与准入门槛

1. **不要把离线计算器冒充完整麻将。** 接 majiang-core.Game 的合法操作/事件状态机，支持人类出牌与 AI 响应，四家闭环；逐项标注未实现的鸣牌、立直、振听、流局、连庄、终局结算。只支持弃牌的 Day 1 原型不能叫标准规则 RC。
2. **一个权威状态。** Node 核心拥有比赛状态；Godot 只渲染快照及请求合法动作。JSON 协议带 version、requestId、matchId、stateRevision；过期/重复 action 明确拒绝。禁止 Godot 和 Node 各发一套牌。
3. **公平性与信息隔离。** AI 不读取其他玩家手牌或牌墙；UI 只接收当前玩家可见信息。角色技能可以改变训练/经营，不能偷改 Classic 发牌、摸牌、和牌概率。
4. **打包不是开发机能运行。** 发行包须携带经许可审查的 Node runtime 或其他可独立执行封装，禁止依赖用户机器上 npm/node/Godot editor。路径带空格/中文、子进程失败、EOF、超时、关游戏进程回收必须测。
5. **通信开销。** 优先长驻受控 sidecar；每次出牌起一个进程可能迟滞且难维护状态。若 Day 1 使用命令式短进程，必须写明是临时路线，实测耗时和序列化完整性，不得用全量 hidden state 到 UI 降低开发难度。
6. **测试门。** 锁定 core 提交运行原测试；Adapter 做正常动作、非法动作、无役、振听、鸣牌、杠、流局、终局与固定种子重放；批量 AI 记录 seed、回合数、终止原因、时间和错误，不能只记“跑了很多局”。
7. **存档门。** 保存经营快照 + version + 原子写/备份；对局中存档若不支持必须明确禁用。奖励按 matchId 幂等，加载不额外发钱。损坏档不能静默归零覆盖原档。
8. **许可门。** 选定库保留完整 LICENSE 和 copyright；锁版本及 hash；发布包生成 THIRD_PARTY_NOTICES，Node 与 Godot 内含 third-party 单独列出。MIT/Apache 不豁免素材许可。Steam 平台法律条款不能自动替用户同意。
9. **范围门。** 本周不开发 Nakama、P2P、抽卡支付、Pandora 编辑器、LimboAI 行为树或正式角色图；GodotSteam 尚未核验的新源不得抢跑引入。

## 有成熟候选仍做局部自研的明确理由（需同步 DECISIONS）

- 原生 Control/Container 的原创麻将桌布局不是重写 UI 框架；可见 Godot 卡牌候选 AGPL，不合商业主仓策略。仅自写产品布局和 tile 文字按钮，不做通用卡牌引擎。
- 存档持久化复用 Godot FileAccess/JSON，少量 schema migration、经济与奖励逻辑是产品专有行为。Pandora 明示 alpha 且不是原子存档保障；LimboAI 解决不同问题，不为“复用”强上插件。
- 联赛业务首版固定赛程/积分/晋级的成本低于部署在线服务。Nakama 保留未来在线排行榜接口隔离，不进入七天关键路径。
- 初始测试使用引擎 headless 与 Node 内建 runner 是复用标准工具；gdUnit4 未经具体 Godot 版本匹配不能贸然引入。成熟插件应在能够净节省时间时再加，不以自建测试框架替代它。

## 验证、交付与回滚记录

已执行：GitHub 官方 API 拉取 12 个仓库元数据、默认分支 commit 与测试树证据；读取 majiang-core LICENSE/package、majiang-ai package、mahjong pyproject、GodotSteam/Pandora README；本地 clone SHA 与 core API SHA 相同。
未执行：候选测试套件、覆盖率计算、插件安装、Windows 导出、商业法律最终意见、Codeberg 新源核验。不能把本报告当成以上验证完成。
变更：只新增本报告与 work/research/repo-evidence.json；无既有报告被覆盖（落盘前不存在）；未改产品源码、未安装依赖。回滚：保留原始 evidence，撤回本报告选择不会影响运行工程；主工程实际集成须另有依赖 lock/commit 和独立回滚记录。

验收结论：GitHub-first 第一轮模块覆盖与候选筛选完成；majiang-core 为明确首选，但标准完整对局、Windows standalone 和 Release Gate 尚待主任务实测通过。估算不是承诺；本报告不把“发现测试”写成“测试通过”。
