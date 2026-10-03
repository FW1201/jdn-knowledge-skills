---
name: jdn-kb-intake
description: >
  JDN LLM Wiki 知識入庫 Skill。
  當使用者執行 /wiki ingest、說「入庫」「把這個加進知識庫」「讀取 raw/」
  「新素材入庫」「更新 wiki」時觸發。
  讀取 raw/ 目錄中的新素材，生成或更新 wiki/ 頁面，
  並同步更新 wiki/index.md 與 wiki/log.md。
  產出使用 JDN- 前綴 frontmatter 欄位，符合 JDN LLM Wiki 1.0 規格。
version: 1.1.0
---

# JDN KB Intake — 知識入庫

將 `raw/` 原始素材轉換為結構化 wiki 頁面。

## 前置條件

執行前先讀取以下文件（若存在）：
1. `WIKI.md` — 系統規格與欄位定義
2. `wiki/index.md` — 現有頁面清單（避免重複入庫）
3. `wiki/log.md` — 操作歷史（了解最近動作）

---

## 工作流程

### Phase 1：掃描新素材

列出 `raw/` 目錄中尚未入庫的檔案：
- 對照 `wiki/index.md` 的 `JDN-sources` 欄位，找出未被引用的 raw 路徑
- 列出清單，請使用者確認要入庫哪些（或全部）

### Phase 2：分析素材

對每份素材：
1. 讀取全文（PDF 用 pdf-reading skill，其餘直接讀）
2. 判斷素材類型，對應 `JDN-type`（見下方分類表）
3. 判斷所屬角色，對應 `JDN-role`
4. 提取核心概念、重點、引用、數據

### Phase 2b：決策邏輯（新建 vs 更新）

| 條件 | 動作 |
|------|------|
| 新素材，無相關頁面 | 新建頁面 |
| 新素材，有密切相關頁面 | 更新現有頁面，補記新素材來源 |
| 重複素材（已入庫） | 記錄日期，內容未變則跳過 |
| 素材跨多個無關主題 | 拆分為 2+ 頁面 |

### Phase 3：生成 Wiki 頁面

**頁面路徑**：`wiki/{角色目錄}/{kebab-case-title}.md`

**頁面 Frontmatter 規格（JDN- 前綴欄位）**：

```yaml
---
JDN-title: "頁面標題（顯示語言）"
JDN-role: researcher      # editor|researcher|teacher|developer|admin|learner|cross-role
JDN-type: source-summary  # 見類型分類表
JDN-sources:              # 此頁面引用的 raw/ 路徑
  - raw/{角色}/{檔名}
JDN-created: 2026-04-20   # ISO 日期
JDN-updated: 2026-04-20   # ISO 日期
JDN-links: []             # 相關 wiki 頁面路徑（相對路徑）
JDN-tags: []              # 自由標籤（Obsidian 搜尋用）
---
```

**頁面類型分類表**：

| JDN-type | 使用時機 | 範例 |
|----------|---------|------|
| `source-summary` | 摘要單一原始素材 | 論文摘要、文章摘要 |
| `entity` | 描述特定人物、文本、專案、工具 | 作者檔案、專案紀錄 |
| `concept` | 解釋抽象概念或方法 | 研究方法、教學框架 |
| `synthesis` | 連結多份素材產生新洞見 | 文獻綜述、主題分析 |
| `profile` | 描述角色、人物設定 | 教師側寫、系統概覽 |
| `index` | 子命名空間的目錄 | 教科書索引、專案清單 |

**頁面正文結構**：

```markdown
> **TL;DR**（理解層，簡明技術中文）
> 3–5 句。每句一件事；結論先講。

## 摘要

一段話說明此頁面內容。

## 核心概念

主要論點、概念、方法（依素材類型調整）。

## 重點整理

- 要點一
- 要點二
- 要點三

## 延伸連結

- 相關頁面（Obsidian [[wiki-link]] 格式）
- 引用來源

## 備註

（可選）待確認事項、限制說明
```

### Phase 3b：理解層（v1.1 新增）

入庫時同步產生「理解層」，讓頁面不必讀完就能掌握：

1. **TL;DR**：頁首 3–5 句，套用 `jdn-kb-view/references/plain-zh-style.md`（簡明技術中文）。
2. **結構圖**：`JDN-type` 為 `synthesis`、`concept` 或比較類頁面時，在「核心概念」段落後附一張 Mermaid 圖（規格同 jdn-kb-view 的 `diagram`：節點 ≤ 15、節點文字 ≤ 12 字）。
3. 其他類型（`source-summary`、`entity`）只加 TL;DR，不強制畫圖。
4. 理解層只濃縮、不新增：TL;DR 與圖中的每個說法都必須能在正文找到。

> 舊頁面不強制回填；re-ingest 或手動更新時再漸進補上。

### Phase 4：更新索引與日誌

**更新 wiki/index.md**：
在對應角色分類下，加入新頁面條目（格式：`- [標題](路徑) — 一行說明`）

**追加 wiki/log.md**（對齊 JDN_llm_wiki.md §5.1 格式）：
```markdown
## [YYYY-MM-DD] ingest | {素材檔名} | {n} pages created/updated
```

---

## 注意事項

1. `raw/` 目錄中的檔案**絕對不能修改**
2. 若同一素材已入庫（`JDN-sources` 中已有該路徑），改為更新現有頁面而非新建
3. `JDN-links` 要雙向：A 連結 B，B 也要連結 A
4. `JDN-updated` 每次修改頁面都必須更新
5. 入庫後必須執行 Phase 4，確保 index 和 log 同步
6. 理解層（TL;DR／結構圖）是正文的濃縮，不可出現正文沒有的說法
