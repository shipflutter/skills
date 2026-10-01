# ASO 检查清单 — Apple App Store 与 Google Play

面向应用开发者和 AI 智能体的应用商店优化（ASO）检查清单。更新于 **2026-10-01**。
属于 [ShipFlutter](https://shipflutter.app) 出品的 [`aso` 技能](https://github.com/shipflutter/skills/tree/develop/skills/aso) · MIT 许可。

> 本文为译文，以英文原文为准；各语言版本的条目 ID 完全相同：<https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- 在线查看：<https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.zh-Hans.md>
- 原始文本（供智能体读取）：<https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.zh-Hans.md>
- 安装完整技能：`npx skills add shipflutter/skills --skill aso`

---

## 如果你是 AI 智能体，请先读这里

1. **默认模式是审查**（audit）。读取商店页面文案，逐项标记下方所有条目，然后输出报告。只有用户要求修复时才修改文件。**除非用户在本次对话中明确要求，否则绝不上传到 App Store Connect /
   Play Console，也绝不提交审核**。
2. **找到商店页面文案**。fastlane：`fastlane/metadata/ios/<locale>/*.txt`（或
   `fastlane/metadata/<locale>/`）和 `fastlane/metadata/android/<locale>/*.txt`。否则请用户按语言粘贴名称 / 副标题 / 关键词 / 描述，或
   Play 的标题 / 简短说明 / 完整说明。
3. **用代码计数，绝不靠目测**。标有 **(auto)** 的条目由免费脚本检查：
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   （需要 Python 3.10+，只用标准库，无需 API 密钥。）
4. **逐项标记** `✅ pass`（通过）/ `⚠️ improve`（待改进）/ `❌ fail`（未通过）/ `N/A`（不适用），并附上证据（文件、计数、原文引用）。每个
   ⚠️/❌ 都要给出符合字数限制的具体修复方案。使用文末的报告模板。
5. **不要编造数据**。没有实际测量过的搜索量、排名或评分一律不写，改为注明“未测量”（not
   measured）。下文标为 UNCONFIRMED 的内容是工具厂商的观察结论，不是商店规则。

---

## 字数限制一览

| 商店 | 字段 | 上限 | 参与搜索索引 |
|---|---|---|---|
| App Store | 应用名称 | 30 | ✅ 权重最高 |
| App Store | 副标题 | 30 | ✅ |
| App Store | 关键词字段（隐藏） | 100 | ✅ |
| App Store | 推广文本 | 170 | ❌（无需审核即可修改） |
| App Store | 描述 | 4000 | ❌ 不参与 App Store 搜索 |
| App Store | 新功能 | 4000 | ❌ |
| App Store | App 内活动（in-app events）名称 / 简短描述 / 详细描述 | 30 / 50 / 120 | ✅ 活动名称 |
| App Store | App 内购买项目显示名称 / 描述 | 30 / 45 | ✅ 推广的 App 内购买项目 |
| Google Play | 标题 | 30 | ✅ 权重最高 |
| Google Play | 简短说明 | 80 | ✅ |
| Google Play | 完整说明 | 4000 | ✅（没有隐藏的关键词字段） |
| Google Play | 新功能 | 500 | ❌ |

Apple 文档称关键词字段上限为“100 字节”，但 App Store
Connect 实际按字符计数（2026-10-01 实测：一个 100 个字符 / 220 字节的日语关键词字段被成功接受）。

---

## 0. 开始之前

- [ ] **PRE-01** 按用户自己的说法，写下应用要帮用户完成的 3 个核心**任务**（如“和朋友 AA 分账”）、目标用户，以及排名前 5 的竞品。
- [ ] **PRE-02** 选定优先市场：店面（storefront）/ 国家或地区 + 语言，按当前安装量或目标用户规模排序。
- [ ] **PRE-03** 商店页面文案纳入版本控制（fastlane `deliver` / `supply` 元数据），每次改动都能对比差异。
- [ ] **PRE-04** 在做任何改动**之前**记录基线：按优先国家分别记录搜索展示次数、产品页浏览量、转化率、各来源下载量、评分及评分数量（见第 10 节）。
- [ ] **PRE-05** 维护一份变更日志（如 `docs/aso-log.md`）：日期、改动的字段、改前 → 改后、要观察的指标、复查日期。

## 1. 关键词调研

- [ ] **KW-01** 从核心任务和品类名词中选出 5–10 个种子词——不用品牌名，也不要只列功能。
- [ ] **KW-02** 按市场和语言，用各商店自带的**搜索联想**（autocomplete）扩展词表（a–z 逐个字母挖掘长尾词）。联想结果的排序 = 热度信号。
- [ ] **KW-03** 针对每个大词（head term），读一遍排名前 10 的竞品标题 / 副标题，记下它们共用的词。绝不使用竞品的品牌名。
- [ ] **KW-04** 从自家和竞品的**评论**中挖掘用户实际使用的名词和动词。
- [ ] **KW-05** 给每个候选词打分：相关性（0–3，< 2 的舍弃）、热度（联想排位或 Apple Ads 热度）、竞争空间 / 难度（前 10 名中有多少应用在争这个词、它们有多强）。
- [ ] **KW-06** 新应用或小应用先争取能拿下的长尾词（3–4 个词、中等热度、竞争空间大），再去争大词。
- [ ] **KW-07** 每种语言一份**关键词地图**：哪些词归名称 / 标题，哪些归副标题 / 简短说明，哪些归关键词字段 / 完整说明。每个词都有位置，每个位置都有词。
- [ ] **KW-08** 找出已排在第 11–50 名的词——这是成本最低的突破口。
- [ ] **KW-09** **按市场**重新调研——用当地语言研究关键词，而不是从英文翻译。

## 2. App Store 元数据（按语言）

- [ ] **AS-01** (auto) 名称 ≤ 30，副标题 ≤ 30，关键词字段 ≤ 100，推广文本 ≤ 170，描述 ≤ 4000。
- [ ] **AS-02** (auto) 名称、副标题和关键词字段都要填满 ≥ 90%——空着的字符就是白白丢掉的排名。
- [ ] **AS-03** 名称 = 品牌 + 优先级最高的词，读起来自然（如“品牌名：习惯打卡”）。
- [ ] **AS-04** (auto) 副标题要加入**新**词——不重复名称中的任何词。
- [ ] **AS-05** (auto) 关键词字段：用半角逗号分隔，**逗号后不加空格**，末尾不留逗号。
- [ ] **AS-06** (auto) 关键词字段不包含名称或副标题中已有的词，也没有重复词。
- [ ] **AS-07** (auto) 单数**或**复数只用一种，不要两者都写。
- [ ] **AS-08** (auto) 不写浪费字符的词：“app”、“apps”（应用）、“free”（免费）、“iPhone”、“iPad”、“iOS”、“Apple”、品牌名 / 公司名；（人工检查）品类名称。
- [ ] **AS-09** (auto, warning) 优先用单个词而不是词组——Apple 会把同一语言的名称 + 副标题 + 关键词字段中的词自动组合。
- [ ] **AS-10** 任何位置都不出现竞品名称、商标或名人姓名（审核指南 2.3.7、5.2.1）。
- [ ] **AS-11** (auto) 名称、副标题、关键词中不出现价格 / 排名 / 行动号召类词语：“free”（免费）、“best”（最佳）、“#1”（第一）、“sale”（促销）、“% off”（折扣），任何语言都一样（2.3.7）。
- [ ] **AS-12** (auto) 不用表情符号；不把 Apple 商标当作自己名称的一部分（iPhone、Siri…）。
- [ ] **AS-13** **主要类别**选最相关的那个（它会计入文本相关性）；次要类别也已设置。
- [ ] **AS-14** 描述：前 3 行讲清主要任务和佐证；用便于扫读的要点列表；不要拿来堆关键词（App Store 搜索不索引描述），但 Google 网页搜索和 Apple 的标签生成器会读取它。
- [ ] **AS-15** 推广文本用于发布近期动态 / 优惠（无需审核即可修改）。
- [ ] **AS-16** (auto) 隐私政策 URL 和支持 URL 都是 https；（人工检查）两者都能正常打开。
- [ ] **AS-17** App 内购买项目的显示名称说明用户能得到什么，自然的情况下带上搜索词（如“习惯打卡 Pro”）。
- [ ] **AS-18** App 内活动（如有）：在 30 个字符的活动名称中放入关键词；同时最多发布 10 个。
- [ ] **AS-19** **App 标签**（App tags；美国店面，en-US 元数据）：已在 App Store Connect 中检查，并取消选择错误的标签（你无法自行添加标签——请在 en-US 描述中直白地写出使用场景）。
- [ ] **AS-20** 按 2025 年的分级体系（4+ / 9+ / 13+ / 16+ / 18+）填写年龄分级问卷。

## 3. Google Play 元数据（按语言）

- [ ] **GP-01** (auto) 标题 ≤ 30，简短说明 ≤ 80，完整说明 ≤ 4000，新功能 ≤ 500。
- [ ] **GP-02** (auto) 标题和简短说明都填满 ≥ 90%。
- [ ] **GP-03** 标题 = 品牌 + 大词；简短说明 = 一句完整的话，包含 2–3 个次要关键词和主要卖点。
- [ ] **GP-04** (auto) 标题中的关键词出现在完整说明里，并且出现在前 ~300 个字符内。
- [ ] **GP-05** 每个目标词在完整说明中自然出现 2–3 次；用上相关词和同义词；不要罗列关键词。
- [ ] **GP-06** (auto) 任何词的密度都不超过 ~3%（堆砌关键词违反政策）。
- [ ] **GP-07** (auto) 标题 / 简短说明 / 开发者名称：不用表情符号，不重复使用特殊字符（`!!!`、`★★`），不用全大写（品牌本身如此除外）。
- [ ] **GP-08** (auto) 标题、图标和开发者名称中不出现“Free”、“#1”、“Best”、“Top”、“Popular”、“New”、“Editor's choice”、“No ads”（免费、第一、最佳、顶级、热门、全新、编辑精选、无广告），也不出现价格或促销信息——每个翻译版本都一样。
- [ ] **GP-09** 完整说明中不出现没有注明来源的推荐语或匿名用户评价。
- [ ] **GP-10** 完整说明结构清晰：抓人的开头（2 行）→ 用小标题 / 要点列出核心功能 → 佐证 → 行动号召；使用 LLM 可以直接引用的平实句子（如“用 X 来……”），因为 Ask Play / AI highlights（AI 亮点摘要）会读取它。
- [ ] **GP-11** 已设置类别和最多 5 个**标签**（在“商店设置”中）。
- [ ] **GP-12** 已填写联系邮箱、网站和隐私政策；网站上也要介绍这款应用（Ask Play 会读取）。
- [ ] **GP-13** 数据安全（Data safety）表单填写完整，且与应用实际行为一致。

## 4. 本地化

- [ ] **L10N-01** 每个优先市场都有自己的商店页面——不是 Play 的自动翻译，也不是英文。
- [ ] **L10N-02** (auto) 关键词字段 / 简短说明**没有照搬**基础语言的内容。
- [ ] **L10N-03** 本地搜索词来自当地的搜索联想和当地竞品（KW-09）。
- [ ] **L10N-04** App Store **跨语言索引**（cross-localization）：为每个优先店面列出 Apple 在该店面额外索引的语言（美国：en-US + es-MX、ar、zh-Hans、zh-Hant、fr-FR、ko、pt-BR、ru、vi；英国：en-GB；加拿大：en-CA + fr-CA；日本：ja + en-US；其他大多数店面：本地语言 + en-GB），并给每种语言填写**不同的**关键词字段词。
- [ ] **L10N-05** 用于跨语言索引的语言版本，母语者读来仍然通顺正确（真实用户会看到）。
- [ ] **L10N-06** (auto) 中日韩 / 泰语 / 阿拉伯语的商店页面同样要填满上限——这些语言里字段写得太短是最常见的浪费。
- [ ] **L10N-07** 为优先语言本地化截图和配文；阿拉伯语 / 希伯来语使用从右到左的布局。
- [ ] **L10N-08** 用当地语言检查宣传用语（"miễn phí", "gratis", "無料", "무료", "免费"…）。

## 5. 图标、截图、视频

- [ ] **CR-01** 图标：一个清晰的符号，不含文字，缩到 40 px 仍能看清，和前 10 名竞品图标并排时能明显区分。
- [ ] **CR-02** iOS 26：分层的 Liquid Glass 图标已在浅色、深色、着色和透明模式下检查过。
- [ ] **CR-03** (auto, Play) 图标为 512×512 PNG；置顶大图 1024×500，无 alpha 通道，不含排名 / 价格 / 奖项宣传。
- [ ] **CR-04** 截图 1 展示**主要任务**，配文 ≤ 5 个词并包含大词；单独出现在搜索结果里也能让人看懂。
- [ ] **CR-05** 截图 2–3 展示接下来的两个安装理由；每张截图只讲一个卖点。
- [ ] **CR-06** 使用真实的应用界面（App Store 2.3.3）；Play 截图上的文字 ≤ 图片的 20%；不出现“Download now”（立即下载）、“#1”、“Best”（最佳）或商店徽章。
- [ ] **CR-07** App Store：6.9 英寸 iPhone 截图组（1320×2868 / 1290×2796 / 1260×2736），应用支持 iPad 时还需 13 英寸 iPad 截图组（2064×2752 / 2048×2732）；每组最多 10 张；无 alpha 通道。
- [ ] **CR-08** (auto) Play：2–8 张手机截图，边长 320–3840 px，长边 ≤ 短边的 2 倍；需有 ≥ 4 张达到 ≥ 1080 px（9:16 或 16:9）才有资格获得推荐展示；如支持平板 / Chromebook / Wear，也要提供对应截图组（按设备类型分别展示）。
- [ ] **CR-09** 视频（可选，需测试验证效果）：App Store 的 App 预览 15–30 秒，只用屏幕录制画面，前 3 秒在静音状态下就能看出核心任务；Play 的 YouTube 链接设为公开 / 不公开列出，关闭广告，前 30 秒最关键。
- [ ] **CR-10** 素材与关键词地图一致：用户搜什么，截图 1 就展示什么。

## 6. 自定义页面与实验

- [ ] **EXP-01** 为主要的关键词搜索意图创建 App Store **自定产品页**（custom product pages，最多 70 个），每个页面分配已获批关键词字段中的关键词。
- [ ] **EXP-02** 为高价值搜索关键词 / 国家或地区 / 流失用户创建 Google Play **自定义商品详情**（custom store listings，最多 50 个）。
- [ ] **EXP-03** 头号市场上始终有一个实验在运行：App Store 产品页优化（product page optimization，≤ 3 个处理方案，≤ 90 天）或 Play 商品详情实验（store listing experiments，≤ 2 个变体；标题和视频不能测试）。
- [ ] **EXP-04** 每个测试：只改一个变量，写下假设和成功指标，运行 ≥ 7 天，达到后台给出的置信度后才停止。
- [ ] **EXP-05** 按预期提升幅度安排测试顺序：图标 → 截图 1 → 配文 → 截图顺序 → 视频。
- [ ] **EXP-06** 记录结果（胜 / 负 / 持平），把胜出方案作为新测试推到其他语言，而不是想当然地直接套用。

## 7. 评分与评论

- [ ] **RV-01** 在用户获得成功体验后弹出系统原生的应用内评分请求（`requestReview` / Play In-App Review API）；绝不在启动时、出错后弹出，也不做好评筛选（gating）；不提供任何奖励诱导。
- [ ] **RV-02** 每个优先国家的平均评分 ≥ 4.0（Play 按国家和设备类型分别计算评分，近期评分权重更高）。
- [ ] **RV-03** 1–3★ 评论在几天内给出有针对性的回复；修复上线后再回复一次。
- [ ] **RV-04** 明确最常被反复提到的差评点，并已列入路线图——两个商店的 AI 评论摘要都会把它作为标题突出展示。
- [ ] **RV-05** 每月挖掘一次评论内容，寻找新关键词和功能需求。

## 8. 质量与技术信号

- [ ] **Q-01** Play Android vitals 低于不良行为阈值（28 天）：用户感知的崩溃率 < 1.09%，ANR < 0.47%，单一机型 < 8%；部分唤醒锁（partial wake lock）使用过度的会话占比 < 5%。
- [ ] **Q-02** 已为 Play 将于 2027 年二月开始执行的内存 / 位图 / DEX 阈值做好准备。
- [ ] **Q-03** Play 新应用 / 更新的目标 API 级别为 36（自 2026-08-31 起）；Apple 构建使用 Xcode 26 SDK（自 2026-04-28 起）。
- [ ] **Q-04** 应用至少每 1–3 个月更新一次；新功能说明写的是真实改动（2.3.12）。
- [ ] **Q-05** 控制下载体积；首次启动不崩溃，也不在用户看到价值之前就强制登录。
- [ ] **Q-06** 已申报隐私营养标签 / 数据安全，以及（可选，App Store）辅助功能营养标签（Accessibility Nutrition Labels）。

## 9. 政策——拒审与下架检查

- [ ] **POL-01** 没有误导性宣传、虚假评价、无法证实的“#1” / “best”（第一 / 最佳），名称 / 标题中不含价格（App Store 2.3.1、2.3.7；Play 元数据政策）。
- [ ] **POL-02** App Store 元数据中不出现其他平台的名称（如“Android”、“Google Play”；2.3.10）。
- [ ] **POL-03** 不使用第三方商标或山寨名称（5.2.1；Play 冒充行为政策）。
- [ ] **POL-04** “For Kids” / “For Children”（儿童专用 / 适合儿童）只能用于“儿童”类别（2.3.8）。
- [ ] **POL-05** 截图 / 预览：展示应用的实际使用画面，而不只是启动页或登录页（2.3.3、2.3.4）。
- [ ] **POL-06** 每个翻译版本都遵守同样的规则（Play 会按语言分别执行政策）。

## 10. 衡量与迭代

- [ ] **M-01** App Store Connect → 分析（Analytics）：App Store 搜索展示次数、产品页浏览量、转化率、下载量——按国家和按自定产品页分别查看。
- [ ] **M-02** Play Console → 发展概览（Grow overview）/ 统计信息（Statistics）：按**搜索字词**和流量来源查看用户获取（“商店分析”（Store analysis）已于 2026 年六月下线；商品详情指标于 2026 年七月改为按独立用户点击计算——不要跨这个日期做对比）。
- [ ] **M-03** 跟踪关键词地图中各词的排名（排名追踪工具、Apple Ads 搜索词报告，或每月重跑一次搜索联想）。
- [ ] **M-04** 每次只改一组字段；等 2–4 周再下结论；App Store 的名称 / 副标题 / 关键词只能随新版本修改。
- [ ] **M-05** 每月：删掉 4–6 周后仍无展示的关键词字段词，补上下一批候选词，重新检查竞品和季节性因素。

---

## 报告模板

```markdown
# ASO 审查 — <应用> — <日期>

商店：<App Store / Google Play> · 语言：<列表> · 模式：<审查 / 修复>

## 得分
<通过数>/<总数> 项 · <n> ❌ · <n> ⚠️ · 脚本：<aso_check 得分行>

## 字段表
| 商店 | 语言 | 名称/标题 | 副标题/简短说明 | 关键词 | 描述 |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## 问题（按影响从大到小）
| ID | 状态 | 商店 · 语言 · 文件 | 证据 | 修复方案（符合字数限制） |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | 名称中也有“tracker” | 替换为“routine”（+7 个字符） |

## 关键词地图（每种优先语言）
| 词 | 相关性 | 联想排位 | 竞争空间 | 字段 |

## 接下来的 3 项行动
1. …
```

## 资料来源

- Apple：[搜索](https://developer.apple.com/app-store/search/) ·
  [平台版本信息](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [App Store 本地化](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [审核指南](https://developer.apple.com/app-store/review/guidelines/) ·
  [截图规格](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [自定产品页](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [App 标签](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google：[商店页面最佳实践](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [元数据政策](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [预览素材](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [自定义商品详情](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [商品详情实验](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Play 新动态](https://google.play/business/whats-new/)
- 各商店的详细说明和日期：[`references/app-store.md`](../references/app-store.md)、
  [`references/google-play.md`](../references/google-play.md)、
  [`references/conversion.md`](../references/conversion.md)、
  [`references/keyword-research.md`](../references/keyword-research.md)、
  [`references/tools.md`](../references/tools.md)。
