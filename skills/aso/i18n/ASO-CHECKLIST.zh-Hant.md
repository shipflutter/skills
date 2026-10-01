# ASO 檢查清單 — Apple App Store 與 Google Play

給應用程式開發者和 AI 代理使用的 ASO（應用程式商店最佳化）檢查清單。更新於 **2026-10-01**。
收錄於 [ShipFlutter](https://shipflutter.app) 的 [`aso` 技能](https://github.com/shipflutter/skills/tree/develop/skills/aso) · MIT 授權。

> 這是翻譯版本。以英文原文為準，各語言版本的條目 ID 都相同：<https://github.com/shipflutter/skills/blob/develop/skills/aso/ASO-CHECKLIST.md>

- 線上檢視：<https://github.com/shipflutter/skills/blob/develop/skills/aso/i18n/ASO-CHECKLIST.zh-Hant.md>
- 原始檔（供 AI 代理讀取）：<https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/i18n/ASO-CHECKLIST.zh-Hant.md>
- 安裝完整技能：`npx skills add shipflutter/skills --skill aso`

---

## 如果你是 AI 代理，請先讀這段

1. **預設模式是審查。** 讀取商店資訊，逐一標記下方每個條目，然後回報。只有使用者要求修正時才編輯檔案。
   **除非使用者在這次對話中提出要求，否則絕不上傳到
   App Store Connect / Play Console，也絕不送審。**
2. **先找到商店資訊。** fastlane：`fastlane/metadata/ios/<locale>/*.txt`（或
   `fastlane/metadata/<locale>/`）以及 `fastlane/metadata/android/<locale>/*.txt`。
   如果找不到，請使用者貼上每種語言的名稱 / 副標題 / 關鍵字 / 描述，或 Play 的標題 /
   簡短說明 / 完整說明。
3. **用程式計算，絕不用肉眼數。** 標示 **(auto)** 的條目會由免費腳本檢查：
   ```bash
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/aso_check.py
   python3 aso_check.py --root .            # markdown report; exit 1 on errors
   curl -sSLO https://raw.githubusercontent.com/shipflutter/skills/develop/skills/aso/scripts/keyword_suggest.py
   python3 keyword_suggest.py "habit tracker" --az --country us --competition
   ```
   （需要 Python 3.10+，只用標準函式庫，不需要 API 金鑰。）
4. **為每個條目標記** `✅ pass`（通過）/ `⚠️ improve`（待改善）/ `❌ fail`（未通過）/ `N/A`（不適用），並附上證據（檔案、字元數、原文引述）。
   每個 ⚠️/❌ 都要提出符合字數上限的具體修正。請使用文末的報告範本。
5. **不要捏造數據。** 沒有實際測量過的搜尋量、排名或評分一律不寫，請註明「未測量」。
   下文標示 UNCONFIRMED 的內容是 ASO 工具廠商的觀察，不是商店規則。

---

## 各欄位上限一覽

| 商店 | 欄位 | 上限 | 是否列入搜尋索引 |
|---|---|---|---|
| App Store | App 名稱 | 30 | ✅ 權重最高 |
| App Store | 副標題 | 30 | ✅ |
| App Store | 關鍵字欄位（不公開） | 100 | ✅ |
| App Store | 推廣文字 | 170 | ❌（不需審查即可修改） |
| App Store | 描述 | 4000 | ❌ 不列入 App Store 搜尋 |
| App Store | 新功能 | 4000 | ❌ |
| App Store | App 內活動名稱 / 簡短說明 / 詳細說明 | 30 / 50 / 120 | ✅ 活動名稱 |
| App Store | App 內購買項目顯示名稱 / 描述 | 30 / 45 | ✅ 推廣中的 App 內購買項目 |
| Google Play | 標題 | 30 | ✅ 權重最高 |
| Google Play | 簡短說明 | 80 | ✅ |
| Google Play | 完整說明 | 4000 | ✅（沒有隱藏的關鍵字欄位） |
| Google Play | 版本資訊 | 500 | ❌ |

Apple 文件把關鍵字欄位上限寫成「100 個位元組」，但
App Store Connect 實際計算的是字元數（2026-10-01 實測：100 個字元、220 個位元組的日文欄位仍可儲存）。

---

## 0. 開始之前

- [ ] **PRE-01** 用使用者的話寫下應用程式的 3 個核心**用途**（例如「和朋友分攤帳單」）、目標受眾，以及前 5 名競爭對手。
- [ ] **PRE-02** 選定優先市場：店面 / 國家 + 語言，依目前安裝量或目標使用者數排序。
- [ ] **PRE-03** 商店資訊納入版本控制（fastlane `deliver` / `supply` 中繼資料），每次修改都能比對差異。
- [ ] **PRE-04** 在任何修改**之前**記錄基準數據：每個優先國家的搜尋曝光次數、產品頁面瀏覽次數、轉換率、各來源下載量、評分與評分數量（見第 10 節）。
- [ ] **PRE-05** 有一份變更紀錄（例如 `docs/aso-log.md`）：日期、修改的欄位、修改前 → 修改後、要觀察的指標、追蹤日期。

## 1. 關鍵字研究

- [ ] **KW-01** 從用途和類別名詞找出 5–10 個種子關鍵字——不是品牌名稱，也不只是功能名稱。
- [ ] **KW-02** 用各商店自己的**自動完成**建議擴充候選詞，依市場和語言分別進行（a–z 長尾詞）。建議的排列順序 = 熱門程度的訊號。
- [ ] **KW-03** 針對每個熱門關鍵字，讀過前 10 名競爭對手的標題 / 副標題，並記下它們共用的字詞。絕不使用對手的品牌名稱。
- [ ] **KW-04** 從自家和競爭對手的**評論**中，挖出使用者實際使用的名詞和動詞。
- [ ] **KW-05** 為每個候選詞評分：相關性（0–3，< 2 的直接刪除）、熱門程度（自動完成排位或 Apple Ads 熱門度）、開放度 / 難度（前 10 名中有多少應用程式鎖定這個詞、它們有多強）。
- [ ] **KW-06** 新應用程式或小型應用程式先鎖定贏得了的長尾詞（3–4 個詞、中等熱門度、開放度高），再挑戰熱門關鍵字。
- [ ] **KW-07** 每種語言都有一份**關鍵字地圖**：哪些詞歸名稱 / 標題、哪些歸副標題 / 簡短說明、哪些歸關鍵字欄位 / 完整說明。每個詞都有歸屬欄位，每個欄位都有負責的詞。
- [ ] **KW-08** 找出已經排在第 11–50 名的關鍵字——這些是最容易拿下的排名。
- [ ] **KW-09** **每個市場**都重新研究——用當地語言研究關鍵字，而不是從英文翻譯。

## 2. App Store 中繼資料（每種語言）

- [ ] **AS-01** (auto) 名稱 ≤ 30、副標題 ≤ 30、關鍵字欄位 ≤ 100、推廣文字 ≤ 170、描述 ≤ 4000。
- [ ] **AS-02** (auto) 名稱、副標題和關鍵字欄位各自填滿 ≥ 90%——空下的字元就是白白損失的排名機會。
- [ ] **AS-03** 名稱 = 品牌 + 最優先的關鍵字，讀起來要自然（「品牌：習慣追蹤」）。
- [ ] **AS-04** (auto) 副標題要加入**新的**字詞——不重複名稱中的任何字詞。
- [ ] **AS-05** (auto) 關鍵字欄位：用逗號分隔，**逗號後不加空格**，結尾不留逗號。
- [ ] **AS-06** (auto) 關鍵字欄位不含名稱或副標題已有的字詞，本身也沒有重複。
- [ ] **AS-07** (auto) 單數**或**複數擇一，不要兩者都放。
- [ ] **AS-08** (auto) 不放浪費空間的字詞：「app」、「apps」（應用程式）、「free」（免費）、「iPhone」、「iPad」、「iOS」、「Apple」、品牌 / 公司名稱；（人工檢查）類別名稱。
- [ ] **AS-09** (auto, warning) 優先用單字，少用片語——Apple 會把同一語言的名稱 + 副標題 + 關鍵字欄位中的字詞自動組合。
- [ ] **AS-10** 任何地方都不放競爭對手名稱、商標或名人姓名（審查指南 2.3.7、5.2.1）。
- [ ] **AS-11** (auto) 名稱、副標題、關鍵字中不放價格 / 排名 / 行動呼籲字詞：「free」、「best」、「#1」、「sale」、「% off」（2.3.7），任何語言都一樣（如「免費」、「最佳」、「第一」、「特價」、「折扣」）。
- [ ] **AS-12** (auto) 不放表情符號；不把 Apple 商標當成自己名稱的一部分（iPhone、Siri…）。
- [ ] **AS-13** **主要類別**選最相關的那一個（它會計入文字相關性）；次要類別也要設定。
- [ ] **AS-14** 描述：前 3 行寫出主要用途和佐證；用方便快速瀏覽的項目符號；不拿來塞關鍵字（App Store 搜尋不索引描述），但 Google 網頁搜尋和 Apple 的標籤產生器會讀取它。
- [ ] **AS-15** 推廣文字用來放當前消息 / 優惠（不需審查即可修改）。
- [ ] **AS-16** (auto) 隱私權政策 URL 和支援 URL 都是 https；（人工檢查）兩者都能正常開啟。
- [ ] **AS-17** App 內購買項目的顯示名稱要說明使用者會得到什麼，自然的話就帶入搜尋字詞（「習慣追蹤 Pro」）。
- [ ] **AS-18** App 內活動（如有）：在 30 個字元的活動名稱中放入關鍵字；同時最多可發布 10 個。
- [ ] **AS-19** **App 標籤**（App tags；限美國店面、en-US 中繼資料）：已在 App Store Connect 中檢查；取消選取錯誤的標籤（你無法自行新增標籤——請在 en-US 描述中直白寫出使用情境）。
- [ ] **AS-20** 已依 2025 年新制分級（4+ / 9+ / 13+ / 16+ / 18+）填寫年齡分級問卷。

## 3. Google Play 中繼資料（每種語言）

- [ ] **GP-01** (auto) 標題 ≤ 30、簡短說明 ≤ 80、完整說明 ≤ 4000、版本資訊 ≤ 500。
- [ ] **GP-02** (auto) 標題和簡短說明填滿 ≥ 90%。
- [ ] **GP-03** 標題 = 品牌 + 熱門關鍵字；簡短說明 = 一個真正的完整句子，包含 2–3 個次要關鍵字和最主要的好處。
- [ ] **GP-04** (auto) 標題中的關鍵字也出現在完整說明裡，而且在前 ~300 個字元內。
- [ ] **GP-05** 每個目標關鍵字在完整說明中自然出現 2–3 次；搭配相關詞和同義詞；不要列關鍵字清單。
- [ ] **GP-06** (auto) 沒有任何字詞的密度超過 ~3%（堆砌關鍵字違反政策）。
- [ ] **GP-07** (auto) 標題 / 簡短說明 / 開發人員名稱：不放表情符號、不重複特殊字元（`!!!`、`★★`）、不用全大寫（品牌名稱本身如此除外）。
- [ ] **GP-08** (auto) 標題、圖示或開發人員名稱中不放「Free」、「#1」、「Best」、「Top」、「Popular」、「New」、「Editor's choice」、「No ads」（免費、第一、最佳、頂尖、熱門、全新、編輯精選、無廣告）、價格或促銷——每個翻譯版本都一樣。
- [ ] **GP-09** 描述中沒有未註明來源的推薦語或匿名使用者引言。
- [ ] **GP-10** 完整說明要有結構：開場吸睛句（2 行）→ 主要功能（加小標題 / 項目符號）→ 佐證 → 行動呼籲；使用 LLM 能直接引用的平實句子（「用 X 來…」），因為 Ask Play / AI 重點摘要會讀取它。
- [ ] **GP-11** 設定類別和最多 5 個**標籤**（商店設定）。
- [ ] **GP-12** 填寫聯絡電子郵件、網站和隱私權政策；網站也要介紹這個應用程式（Ask Play 會讀取）。
- [ ] **GP-13** 資料安全性（Data safety）表單填寫完整，且與應用程式的實際行為一致。

## 4. 在地化

- [ ] **L10N-01** 每個優先市場都有自己的商店資訊——不是 Play 的自動翻譯，也不是英文。
- [ ] **L10N-02** (auto) 關鍵字欄位 / 簡短說明**沒有直接複製**基準語言的內容。
- [ ] **L10N-03** 從當地的自動完成建議和當地競爭對手找出當地搜尋字詞（KW-09）。
- [ ] **L10N-04** App Store **跨語言在地化**：為每個優先店面列出 Apple 在當地額外索引的語言（美國：en-US + es-MX、ar、zh-Hans、zh-Hant、fr-FR、ko、pt-BR、ru、vi；英國：en-GB；加拿大：en-CA + fr-CA；日本：ja + en-US；其他多數店面：當地語言 + en-GB），並讓每種語言的關鍵字欄位放**不同**的字詞。
- [ ] **L10N-05** 用來做跨語言在地化的語言版本，母語使用者讀起來仍要通順正確（真的會有使用者看到）。
- [ ] **L10N-06** (auto) 中日韓 / 泰文 / 阿拉伯文的商店資訊也要填到上限——這些語言的欄位寫太短，是最常見的浪費。
- [ ] **L10N-07** 為優先語言在地化螢幕截圖和說明文字；阿拉伯文 / 希伯來文使用由右至左的版面。
- [ ] **L10N-08** 用當地語言檢查宣稱字詞（"miễn phí", "gratis", "無料", "무료", "免费"…）。

## 5. 圖示、螢幕截圖、影片

- [ ] **CR-01** 圖示：一個清楚的符號，不放文字，縮到 40 px 仍能辨識，和前 10 名競爭對手的圖示並排時一眼就能區分。
- [ ] **CR-02** iOS 26：分層的 Liquid Glass 圖示已在淺色、深色、著色和透明模式下檢查過。
- [ ] **CR-03** (auto, Play) 圖示為 512×512 PNG；主題圖片為 1024×500，不含 alpha 透明通道，不放排名 / 價格 / 獎項宣稱。
- [ ] **CR-04** 第 1 張螢幕截圖展示**主要用途**，並在 ≤ 5 個詞的說明文字中放入最主要的關鍵字；它在搜尋結果中單獨出現時也要看得懂。
- [ ] **CR-05** 第 2–3 張螢幕截圖展示接下來兩個安裝理由；每張螢幕截圖只講一個好處。
- [ ] **CR-06** 使用真實的應用程式介面（App Store 2.3.3）；Play 的說明文字 ≤ 圖片的 20%；不放「Download now」（立即下載）、「#1」、「Best」（最佳）或商店徽章。
- [ ] **CR-07** App Store：6.9 吋 iPhone 組（1320×2868 / 1290×2796 / 1260×2736），應用程式支援 iPad 的話再加 13 吋 iPad 組（2064×2752 / 2048×2732）；每組最多 10 張；不含 alpha 透明通道。
- [ ] **CR-08** (auto) Play：2–8 張手機螢幕截圖，邊長 320–3840 px，長邊 ≤ 2× 短邊；≥ 4 張達到 ≥ 1080 px（9:16 或 16:9）才有資格獲得推薦；若支援平板 / Chromebook / Wear，也要提供對應的截圖組（依裝置類型分別顯示）。
- [ ] **CR-09** 影片（選用，先測試）：App Store App 預覽影片 15–30 秒，只能用螢幕錄影，前 3 秒不開聲音也要看得出用途；Play 的 YouTube 連結設為公開 / 不公開，關閉廣告，前 30 秒最關鍵。
- [ ] **CR-10** 素材與關鍵字地圖一致：使用者搜尋什麼，第 1 張螢幕截圖就展示什麼。

## 6. 自訂頁面與實驗

- [ ] **EXP-01** 針對主要的關鍵字搜尋意圖建立 App Store **自訂產品頁面**（custom product pages，最多 70 個），每個頁面都從已核准的關鍵字欄位中指派關鍵字。
- [ ] **EXP-02** 針對高價值的搜尋關鍵字 / 國家 / 流失使用者建立 Google Play **自訂商店資訊**（custom store listings，最多 50 個）。
- [ ] **EXP-03** 最重要的市場隨時都有一項實驗在進行：App Store 產品頁面最佳化（product page optimization，≤ 3 個實驗版本，≤ 90 天），或 Play 商店資訊實驗（store listing experiments，≤ 2 個變化版本；標題和影片無法測試）。
- [ ] **EXP-04** 每項測試：只改一個變數、寫下假設、訂好成功指標、執行 ≥ 7 天，達到主控台顯示的信賴水準才停止。
- [ ] **EXP-05** 依預期提升幅度排定測試順序：圖示 → 第 1 張螢幕截圖 → 說明文字 → 螢幕截圖順序 → 影片。
- [ ] **EXP-06** 記錄結果（勝 / 負 / 持平），並把勝出版本當作新測試套用到其他語言，而不是直接假設有效。

## 7. 評分與評論

- [ ] **RV-01** 在使用者體驗到成功的時刻之後，使用原生的應用程式內評論提示（`requestReview` / Play In-App Review API）；絕不在啟動時、出錯後跳出，也不先篩選使用者（review gating）；不提供任何獎勵。
- [ ] **RV-02** 每個優先國家的平均評分 ≥ 4.0（Play 依國家和裝置類型分別計算評分，近期評分的權重較高）。
- [ ] **RV-03** 在幾天內具體回覆 1–3★ 評論；修正上線時再回覆一次。
- [ ] **RV-04** 掌握最常反覆出現的抱怨，並排入產品路線圖——兩個商店的 AI 評論摘要都會把它當成重點標題顯示。
- [ ] **RV-05** 每月從評論內容挖掘新關鍵字和功能需求。

## 8. 品質與技術訊號

- [ ] **Q-01** Play Android vitals 低於不良行為門檻（28 天）：使用者感知的當機率 < 1.09%、ANR < 0.47%、單一手機型號 < 8%；過度的部分喚醒鎖定 < 5% 的工作階段。
- [ ] **Q-02** 已為 2027 年二月起執行的 Play 記憶體 / 點陣圖 / DEX 門檻做好規劃。
- [ ] **Q-03** Play 新應用程式 / 更新的目標 API 級別為 36（自 2026-08-31 起）；Apple 建置使用 Xcode 26 SDK（自 2026-04-28 起）。
- [ ] **Q-04** 至少每 1–3 個月更新一次應用程式；「新功能」寫出真實的變更（2.3.12）。
- [ ] **Q-05** 下載大小盡量小；首次啟動不當機，也不在使用者看到價值之前就用登入畫面擋住。
- [ ] **Q-06** 已申報隱私權營養標籤 / 資料安全性，以及（選用，App Store）輔助使用營養標籤（Accessibility Nutrition Labels）。

## 9. 政策：審核被拒與下架檢查

- [ ] **POL-01** 名稱 / 標題中沒有誤導性宣稱、假評論、無法驗證的「#1」/「best」或價格（App Store 2.3.1、2.3.7；Play 中繼資料政策）。
- [ ] **POL-02** App Store 中繼資料不提及其他平台的名稱（「Android」、「Google Play」）（2.3.10）。
- [ ] **POL-03** 不使用第三方商標或仿冒名稱（5.2.1；Play 冒用他人身分政策）。
- [ ] **POL-04** 「For Kids」/「For Children」（兒童專用）只能用在兒童類別（2.3.8）。
- [ ] **POL-05** 螢幕截圖 / 預覽影片：展示應用程式實際使用的畫面，而不只是啟動畫面或登入畫面（2.3.3、2.3.4）。
- [ ] **POL-06** 每個翻譯版本都遵守同樣的規則（Play 依語言分別套用政策）。

## 10. 衡量與迭代

- [ ] **M-01** App Store Connect → Analytics（分析）：App Store 搜尋曝光次數、產品頁面瀏覽次數、轉換率、下載量——依國家及依自訂產品頁面分別查看。
- [ ] **M-02** Play Console → Grow overview / Statistics（成長總覽 / 統計資料）：依**搜尋字詞**和流量來源查看使用者取得情況（「商店分析」Store analysis 已於 2026 年六月停用；商店資訊指標於 2026 年七月改為計算不重複使用者點擊次數——不要跨這個日期比較）。
- [ ] **M-03** 追蹤關鍵字地圖中各關鍵字的排名（排名追蹤工具、Apple Ads 搜尋字詞報告，或每月重跑一次自動完成建議）。
- [ ] **M-04** 一次只修改一組欄位；等 2–4 週再評估成效；App Store 的名稱 / 副標題 / 關鍵字只能隨新版本修改。
- [ ] **M-05** 每月：刪除 4–6 週後仍沒有曝光的關鍵字欄位字詞，補上下一批候選詞，重新檢查競爭對手和季節性。

---

## 報告範本

```markdown
# ASO 審查 — <App 名稱> — <日期>

商店：<App Store / Google Play> · 語言：<清單> · 模式：<審查 / 修正>

## 分數
<通過數>/<總數> 個條目 · <n> ❌ · <n> ⚠️ · 腳本：<aso_check 分數那一行>

## 欄位表
| 商店 | 語言 | 名稱/標題 | 副標題/簡短說明 | 關鍵字 | 描述 |
|---|---|---|---|---|---|
| App Store | en-US | 28/30 ✅ | 30/30 ✅ | 97/100 ✅ | 3120/4000 ✅ |

## 問題（影響最大的排最前）
| ID | 狀態 | 商店 · 語言 · 檔案 | 證據 | 修正（符合字數上限） |
|---|---|---|---|---|
| AS-06 | ❌ | App Store · en-US · keywords.txt | "tracker" 已出現在名稱中 | 改成 "routine"（+7 個字元） |

## 關鍵字地圖（每個優先語言）
| 字詞 | 相關性 | 自動完成排位 | 開放度 | 欄位 |

## 接下來的 3 個行動
1. …
```

## 資料來源

- Apple：[搜尋](https://developer.apple.com/app-store/search/) ·
  [平台版本資訊](https://developer.apple.com/help/app-store-connect/reference/platform-version-information) ·
  [App Store 在地化](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) ·
  [審查指南](https://developer.apple.com/app-store/review/guidelines/) ·
  [螢幕截圖規格](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications/) ·
  [自訂產品頁面](https://developer.apple.com/help/app-store-connect/create-custom-product-pages/configure-multiple-product-page-versions/) ·
  [App 標籤](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-tags)
- Google：[商店資訊最佳做法](https://support.google.com/googleplay/android-developer/answer/13393723) ·
  [中繼資料政策](https://support.google.com/googleplay/android-developer/answer/9898842) ·
  [預覽素材](https://support.google.com/googleplay/android-developer/answer/9866151) ·
  [自訂商店資訊](https://support.google.com/googleplay/android-developer/answer/9867158) ·
  [商店資訊實驗](https://support.google.com/googleplay/android-developer/answer/6227309) ·
  [Android vitals](https://developer.android.com/topic/performance/vitals) ·
  [Play 最新消息](https://google.play/business/whats-new/)
- 各商店的詳細資訊與日期：[`references/app-store.md`](../references/app-store.md)、
  [`references/google-play.md`](../references/google-play.md)、
  [`references/conversion.md`](../references/conversion.md)、
  [`references/keyword-research.md`](../references/keyword-research.md)、
  [`references/tools.md`](../references/tools.md)。
