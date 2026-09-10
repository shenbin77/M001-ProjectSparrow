# Decisions / 决策与证据

## D001 — 2026-09-11 / 用户已批准的方向
M001 ACTIVE、G002 PARKED/READY；7天冲刺到2026-09-17，以Windows RC为代码目标，Steam以实际账户/平台许可为界。既有聊天较早的30天/数月建议已被本轮7天要求覆盖。无需重复确认技术方向。

## D002 — 新目录与回滚
当前工作目录没有游戏工程。使用 outputs/ProjectSparrow 独立项目根目录，不修改 D:/温州麻将。后者是不同规则与用途的已有项目。新项目基线为空；首次文档/代码创建无覆盖旧文件。后续修改前保留Git检查点或work中的备份，避免破坏性恢复。

## D003 — Godot + Node规则进程
没有发现现成Godot安装；下载官方固定4.6.1版本。保留Godot优先，不改为网页游戏。直接复用majiang-core MIT原始JS，比翻译成GDScript更容易核验；成本为Node运行时与进程通信。首日重演式请求优先正确性与易测试；若性能不合格升级为长驻stdio进程，不暴露HTTP端口。维护私有接口依赖必须在适配测试记录。

## D004 — 自研边界
只自写产品特有俱乐部/技能/剧情/奖励薄层与UI。通用牌型、计分、向听、合法动作、对局机直接复用。存档先用Godot FileAccess原生API，不引入新的框架；原因是本周数据规模小，额外插件并不能省掉schema与损坏恢复验证。联赛只是本产品的节点与积分数据；不引入线上联赛服务。对话与测试插件调研后按实际需要接入，不为“用了插件”扩大依赖。

## D005 — 第一检查点不冒充RC
第一可运行场景只能标pre-alpha/开发检查点。单局挑战不是完整东风/半庄职业赛事。功能未完成不能写成已完成；正式RC需过ARCHITECTURE列出的完整Gate。占位视觉一直保留到本周结束。

## D006 — 环境失败与Worker
旧知识库 SCHEMA/总索引/START-HERE入口读取失败，未找到M001项目笔记，不凭旧路径伪造上下文。当前用户需求与本地项目文档优先。本地Qwen 8080与免费代理18906拒绝连接；组合启动请求被执行策略拒绝，未绕过限制。改探测OpenCode官方免费模型；远程调用仅发送本项目原创非敏感需求，不发送凭证或旧私人文件。默认付费模型不自动调用。

## D007 — Steam门槛
官方来源 https://partner.steamgames.com/steamdirect?l=english ，2026-09-11核验。通常应用费后至少30天，Coming Soon公开至少2周，并需审核。账户/AppID/付款日/Coming Soon日未知，最早发布日暂不可计算。代码交付不可依赖平台等待。付款、账号授权、法律条款、不可逆发布需用户确认，其余材料准备继续。

## D008 — 连续推进
创建本任务每6小时heartbeat（automationId m001），从CURRENT_STATUS恢复。它依赖桌面应用/主机可运行，不宣称关机后仍能开发。2026-09-17进行真实Gate并暂停到期自动任务；成功/失败/需授权时通知，不刷无变化状态。

## D009 — 用户指定D盘与节约额度
2026-09-11用户补充明确要求D盘文件夹与省Codex额度。主开发根目录迁为 D:\AI-Game-Factory\M001-ProjectSparrow，逐文件SHA256比对零差异后继续，C盘旧目录保留回退，不双线编辑。自动任务m001已经更新新路径。停止新增Codex子代理，后续L1/L2优先OpenCode官方免费mimo-v2.5-free；本地Qwen还未启动成功。

## D010 — 修正Windows进程协议
实测OS.execute JSON argv开局失败。改请求/响应临时JSON文件+OS.create_process异步等待，15秒超时终止本次子进程，保留现有牌局。移除命令行大JSON和引号依赖。公开副露独立字段。不通过用户任意字符串拼接shell命令。

## D011 — 2026-09-11 / 资产批次1归档
15 张概念图从 D 盘根目录「Codex 图像 2026年9月11日 *.png」按视觉识别内容重命名，归档到 D:\AI-Game-Factory\assets\{M001_Project_Sparrow, G002_Project_Legacy, shared}；ASSET_INDEX.md 为资产唯一真相源，15 张全部 CONCEPT_ONLY、可作最终母版=否，角色圣经定稿前不进入游戏。原 17 条 manifest 中 2 张未出现（白鹤秘境_project_sparrow.png、雀影新手的华丽一击.png）待补生成或人工确认；未命名批次图 a_wide_*.png 已识别为 赤雀_世界麻将联盟_阵营地图.png 并入 M001 阵营概念。

## D012 — 2026-09-11 / 俱乐部风格 AI
4 风格 rookie/tensei/pressure/professional 映射 4 家对手俱乐部；风格参数 per-seat 走 ai_profiles 协议，单数 ai_profile 保持基座校验（合法值 rookie/professional）。vendor（majiang-core/majiang-ai）冻结零改动；风格以 subclass 实现于 backend/club-styles.cjs，不触碰引擎内部。

## D013 — 2026-09-11 / 剧情事件引擎
at_match 触发 + events_seen 一次性语义（事件触发后不再重复）。事件状态键全部收纳在存档版本 sv3 内，无 schema bump；残缺旧档 load_from 仅补缺字段、不覆盖已有值（fail-closed：破损值仍拒载，不进默认值兜底）。

## D014 — 2026-09-11 / 技能目录麻将化
game/skills.gd 增量 +5 条技能，仅 training_xp 与 economy 两类效果（局外成长/经济，不改牌山，符合 DND-06 边界）；旧 8 条技能与既有存档数据兼容、不动。data/characters.json 新增 play_style 字段承载牌风；style 键已被 UI 占用，不覆写、不改名。

## D015 — 2026-09-11 / P0 修复：风格误塞 ai_profile
start_match 曾把 tensei/pressure 塞进单数 ai_profile，触发 adapter 基座校验崩溃。修复：风格参数走 ai_profiles（per-seat），ai_profile 恒为 rookie。回归测试 tests/club-ai.test.cjs 覆盖 4 种风格请求形状。

## D016 — 2026-09-11 / 文档拓扑
不拆 M001/G002 子目录：README/CURRENT_STATUS/VERIFY.ps1 等入口均引用 docs/ 当前平铺路径，拆开会全线失效。改为"1 总纲（00_MASTER_VISION）+ 专业文档平铺 + 追加式 DECISIONS/DO_NOT_DO/SCOPE_NOW_NEXT_FUTURE"。子目录拆分记为 RC 通过后的重访项。
