---
name: jdn-kb-query
description: >
  JDN LLM Wiki 知識查詢 Skill。
  當使用者說「查詢知識庫」「在 wiki 裡找」「搜尋知識庫」「wiki 裡有沒有」
  「關於 X 我記錄了什麼」「查一下 wiki」「/wiki query」時觸發。
  讀取 wiki/index.md 定位相關頁面，綜合回答，
  若答案有新洞見則提議存回 wiki。
version: 1.0.0
---

# JDN KB Query — 知識查詢

自然語言查詢 wiki，綜合多頁面回答，並可將有價值的答案存回知識庫。

## 工作流程

### Phase 1：定位相關頁面

1. 讀取 `wiki/index.md` 全文
2. 根據使用者查詢，找出最相關的頁面（按相關度排序，最多 5 頁）
3. 讀取這些頁面的完整內容

若 index.md 不存在，直接掃描 `wiki/**/*.md` 的 frontmatter。

### Phase 2：綜合回答

**頁面優先順序**（對齊 JDN_llm_wiki.md §5.2）：
> synthesis > source-summary > entity > concept

根據頁面內容撰寫回答：

```
📚 來源：
  - [頁面標題](wiki/{路徑}) — {JDN-updated}
  - ...

回答：
[綜合多頁面的答案，用 [標題](路徑) 格式標明引用]

⚠ 缺口：
[若 wiki 沒有覆蓋此問題，說明：「This isn't covered yet — consider ingesting X」]
```

**回答原則**：
- 綜合多頁面時要說明哪部分來自哪個頁面
- 若多頁面有矛盾，明確指出而非靜默選一個
- 若 wiki 中沒有相關資訊，直接說明並建議入庫，不要自行推測

**輸出格式選項**（對齊 §5.2）：
- 預設：Markdown 答案 + 引用連結
- `--marp`：Marp 簡報格式（適合 presentation）
- `--apa`：APA 7th 格式參考清單

### Phase 3：提議存回（可選）

若回答過程中產生了原本 wiki 沒有的新洞見（如跨頁面合成），詢問：

```
💡 此回答整合了 {n} 個頁面的資訊，是否要存為新的 wiki 頁面？
   建議路徑：wiki/{角色}/synthesis-{主題}.md（JDN-type: synthesis）
```

若使用者同意，用 jdn-kb-intake 的 frontmatter 規格建立新頁面，JDN-sources 留空（合成頁）。

---

## 查詢模式

### 精確查詢
```
wiki 裡有關「構式語法」的筆記？
→ 搜尋 JDN-tags 和頁面標題，回傳精確匹配
```

### 模糊查詢
```
我在哪裡記錄過 AI 教育工具？
→ 語義搜尋 wiki 頁面，回傳最相關的 3-5 頁
```

### 角色範圍查詢
```
研究者角色下有哪些文獻摘要？
→ 篩選 JDN-role: researcher + JDN-type: source-summary
```

### 時間範圍查詢
```
上個月新增的頁面有哪些？
→ 篩選 JDN-created 日期範圍
```

---

## 注意事項

1. 永遠先讀 index.md，再讀具體頁面——避免讀取整個 wiki/
2. 回答必須標明來源頁面路徑
3. 不確定時寧可說「wiki 中沒有」，也不要用外部知識補漏而不說明
4. 存回 wiki 前必須問使用者確認
