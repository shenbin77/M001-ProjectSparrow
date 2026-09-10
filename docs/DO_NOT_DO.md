# DO NOT DO — 多 Agent 防犯病清单

更新时间：2026-09-11。本文件只增不删；条目取消必须改为"已撤销 + 理由 + 日期"，不允许直接删除历史。
每条含 **Reason**（为什么禁）与 **Revisit When**（什么条件变化才允许重议）。没有 Revisit 条件的条目 = 永远禁止。

## DND-01 同时主开发 M001 和 G002
- 规则：同一时间窗口内只允许 M001 一个主开发项目；G002 保持 PARKED/READY，不分配实现、正式美术、原型或依赖集成工作（00_MASTER_VISION §3）。
- Reason：资源稀释。7 天冲刺（2026-09-17 截止）预算只够一个项目跑通 RC；双线必然两个都不完成。
- Revisit When：M001 RC 通过 ARCHITECTURE.md 列出的完整 Gate 后，且用户重新排优先级。

## DND-02 重新造已有的成熟麻将规则引擎
- 规则：通用牌型、计分、向听、合法动作、对局机直接复用 majiang-core（MIT，冻结提交 7e96429），禁止自研替代；确有自研理由必须写 DECISIONS.md（00_MASTER_VISION §6 GitHub-first）。
- Reason：已有经 1,026 条上游测试验证的成熟引擎；重写 = 浪费额度 + 引入新错误面。
- Revisit When：只有 majiang-core 出现被证明不可修复的缺陷或许可证变化时（目前无证据）。

## DND-03 7 天冲刺内制作正式角色立绘 / 批量海报
- 规则：游戏内继续用占位色块/剪影；ASSET_INDEX.md 批次 1 的 15 张全部 CONCEPT_ONLY，不进游戏；禁止批量生成正式海报（00_MASTER_VISION §7、GDD §7）。
- Reason：美术周期远超剩余冲刺窗口，且正式母版需先有角色圣经定稿；用占位不阻塞人物数据与剧情开发。
- Revisit When：核心循环经真人试玩验证留存/好感后，且角色圣经（M001 核心 4 人）定稿。

## DND-04 为 Factory Dashboard / 架构优化暂停游戏本体开发
- 规则：任何 Factory/架构工作连续 2 小时未产生"当前 M001 7 天交付路径直接可用"的可运行成果，立即停止，回到可运行游戏（00_MASTER_VISION §2）。
- Reason：产品拖着工厂长出来；工厂功能必须回答"如何直接缩短 M001 交付"，否则是烧额度的自嗨。
- Revisit When：M001 完成发行后，工厂已沉淀真实复用需求。

## DND-05 Classic Ranked 加入付费战力
- 规则：Classic Ranked 永久公平。角色只能提供外观、语音、和牌演出、表情、桌布；不得影响发牌、摸牌、和牌概率（00_MASTER_VISION §7、GDD §8）。
- Reason：付费改胜率是 P2W，直接摧毁竞技信誉与留存北极星。
- Revisit When：**永远不做**。技能影响玩法只允许在明确标注的独立娱乐模式（Ability League / Character Battle）。

## DND-06 角色技能改变发牌/和牌随机性
- 规则：技能效果仅限局外成长、训练经验、经济、AI 决策倾向；不得改牌山、不得改发牌/摸牌/和牌概率（GDD §4 技能暂定约束、CURRENT_STATUS 阻塞项）。
- Reason：规则引擎的公平性边界；一旦牌山被角色影响，Classic 竞技层和联网公平层全部作废。
- Revisit When：只在独立娱乐模式立项时，且该模式须在 UI 明确标注"非公平模式"。

## DND-07 市场验证前批量生成几十个核心角色
- 规则：正式角色按 GDD 节奏（Day2 4 个、Day4 8 个）推进，禁止一次性批量生成几十名"核心 IP"。
- Reason：角色 IP 的价值来自被记住与情感连接；未验证招募/角色吸引力就量产，等于用额度堆尸体。
- Revisit When：招募/球探循环经真人试玩证明"玩家愿意为角色留下"后再扩量。

## DND-08 复制 Fire Emblem（火焰纹章）角色/剧情/UI/美术/音乐
- 规则：G002 红线（G002_PROJECT_LEGACY_GDD 基线、00_MASTER_VISION §6）：可借鉴成熟角色类型语言，禁止复制受保护的具体角色、剧情、UI、美术、音乐表达。
- Reason：法务风险直接封死发行，且与"原创 IP"北极星矛盾。
- Revisit When：**永远不做**。

## DND-09 把 GitHub 许可不明 / GPL 代码直接合入商业主仓
- 规则：优先 MIT/Apache/BSD/MPL；GPL/AGPL/LGPL/不明许可禁止直接合入，除非有明确隔离策略 + 法律影响评估并记录在案；参考算法思想可以，代码合入不行（00_MASTER_VISION §6、OPEN_SOURCE_REUSE_REPORT 基线）。
- Reason：许可证污染使商业发行不可逆地受限。
- Revisit When：仅当法务评估通过且有隔离方案（如独立进程/二进制隔离），逐条记 DECISIONS.md。

## DND-10 没有测试就 merge；只报"完成"不给证据
- 规则：Worker 修改先过测试、Critic 通过再合并，主分支保持可构建；回报必须附 文件清单 / 测试结果 / Build 证据，"文件存在"≠"可玩"（00_MASTER_VISION §4、§8）。
- Reason：无测试 merge = 让后续所有 Agent 在坏地基上施工；无证据回报 = 让验收方无法辨别真伪。
- Revisit When：**永不豁免**。紧急回滚例外须写 DECISIONS.md 并标注"待补测试"。

## DND-11 用 AI 假装真人试玩结论；把概念图标成最终母版
- 规则：AI Playtest 结果必须标注"AI 种子，非真人"（HUMAN_PLAYTEST_PLAN.md 为真人验证路径）；ASSET_INDEX.md 中 CONCEPT_ONLY 资产禁止标记为 FINAL_MASTER，禁止在商店页/游戏内当成品展示。
- Reason：AI 结论不能替代真人留存/情感数据；概念图冒充母版会在发行日变成已知问题黑名单里的自爆点。
- Revisit When：AI 项在真人 1–2 小时试玩补证后更新口径；概念图在角色圣经定稿 + 重绘后由 ASSET_INDEX.md 改状态。
