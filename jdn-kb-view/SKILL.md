---
name: jdn-kb-view
description: >
  JDN LLM Wiki 理解格式 Skill（View Layer）。把 wiki 知識轉成「最容易被理解」的輸出：
  簡明技術中文、結構圖、互動網頁、解說影片分鏡。
  當使用者說「/wiki query --as」「用簡單的話講」「畫成圖」「做成網頁」「做成解說影片」
  「看不懂，換個方式說明」「用 STE 寫」「簡明技術中文」「幫我選最好懂的格式」時觸發；
  也由 jdn-kb-query（--as 參數）與 jdn-kb-intake（理解層）呼叫。
  核心原則：wiki 是持久知識層，所有輸出都是可拋棄、可重生的檢視層。
version: 1.0.0
---

# JDN KB View — 理解格式層

> 設計來源：Andrej Karpathy（2026-10-02）的「理解力輸出階梯」——LLM 做的事愈多，人的工作愈往上移到**監督與理解**；
> 輸出格式應依「理解成本」挑選：受控文字 → 圖 → 互動網頁 → 解說影片。

## 核心原則

1. **知識存一次，檢視可重生**：wiki 頁面是唯一真實來源；本 Skill 產出的是 view，不回寫成知識頁。
2. **存配方，不一定存成品**：每次產出在 `wiki/log.md` 記錄「查詢＋格式＋來源頁」，需要時可重新產生。
3. **愈漂亮愈要查證**：第 3、4 階（網頁、影片）渲染前必須通過查證閘門（見 Phase 3）。
4. **不重造輪子**：第 3、4 階若環境已有專用 Skill（網頁產生器、程式動畫／影片 Skill），本 Skill 只產出規格與分鏡，交給它執行。

---

## 四階格式

| `--as` | 階 | 產出 | 適合 | 成本 |
|---|---|---|---|---|
| `ste` | 1 | 簡明技術中文段落（見 `references/plain-zh-style.md`） | 定義、步驟、規則、快速答覆 | 極低 |
| `diagram` | 2 | Mermaid 圖，直接內嵌 Markdown | 流程、層級、因果、比較 | 低 |
| `html` | 3 | 單檔可互動 HTML | 需要探索、篩選、操作參數的主題 | 中 |
| `video` | 4 | 分鏡 JSON＋旁白稿（交給影片 Skill 渲染） | 機制解說、教學、對外說明 | 高 |
| `auto` | — | 依下方路由規則選擇 | 使用者未指定時 | — |

---

## 工作流程

### Phase 1：取得內容

- 由 jdn-kb-query 呼叫：沿用其已讀取的來源頁與綜合答案。
- 單獨觸發：先依 jdn-kb-query Phase 1 讀 `wiki/index.md` 定位頁面（最多 5 頁）。
- 建立 **claim 清單**：把答案拆成可查證的事實句，每句標註來源頁路徑。

### Phase 2：選擇格式（`--as auto`）

依序判斷，命中即停：

1. 使用者指定格式 → 照用。
2. 內容是**步驟／規則／定義**，且少於約 300 字 → `ste`
3. 內容有**結構**（≥3 個節點彼此有關係：流程、層級、因果、對照）→ `diagram`
4. 讀者需要**自行探索**（多維比較、可調參數、篩選）→ `html`
5. 內容是**隨時間展開的機制**，或要給非專業聽眾看 → 建議 `video`，但先告知成本、取得同意。
6. 其他 → `ste`

> 預設往低階選：能用低階講清楚，就不升階。升階前一句話說明理由。

### Phase 3：查證閘門（`html` / `video` 必做；`diagram` 建議做）

渲染前輸出：

```
🔎 查證閘門
- [✓] claim 1 … ← wiki/{路徑}
- [✓] claim 2 … ← wiki/{路徑}
- [?] claim 3 … ← 無來源（將刪除或標示「推論」）
```

- 無來源的 claim：刪除，或在成品中明確標示「推論」。
- 不得以外部知識補充而不註明。

### Phase 4：產出

**`ste`**：套用 `references/plain-zh-style.md`；結尾附「來源：[標題](路徑)」。

**`diagram`**：
- 使用 Mermaid（`flowchart` / `mindmap` / `sequenceDiagram` / `quadrantChart` 擇一）。
- 節點 ≤ 15 個；節點文字 ≤ 12 字；超過就拆成兩張圖。
- 圖下附 2–3 句簡明說明＋來源。

**`html`**：
- 單一檔案、無建置步驟；外部函式庫只用公開 CDN。
- 必含：標題、一句話摘要、互動區、「資料來源」區（列出 wiki 頁）。
- 存放：`artifacts/views/YYYY-MM-DD-{slug}.html`（若專案無 `artifacts/`，詢問存放位置）。
- 若環境提供網頁發佈／Artifact 能力，可直接發佈並回傳連結。

**`video`**：只產出規格，不在本 Skill 內渲染：

```json
{
  "title": "…",
  "style": "3b1b-like explainer",
  "duration_sec": 90,
  "scenes": [
    { "id": 1, "narration": "…（簡明技術中文）", "visual": "…", "claims": ["wiki/…"] }
  ]
}
```

存成 `artifacts/views/YYYY-MM-DD-{slug}.storyboard.json`，再交給環境中的影片／程式動畫 Skill；若沒有，告知使用者可用的替代方式。旁白一律套用 `plain-zh-style`。

### Phase 5：記錄配方

追加 `wiki/log.md`：

```
## [YYYY-MM-DD] view | {主題} --as {格式}
- 來源：wiki/{路徑1}, wiki/{路徑2}
- 成品：{檔案路徑或「未保存」}
```

---

## 注意事項

1. view 不是知識：除非使用者要求，不把 view 成品寫回 `wiki/` 知識頁。
2. 若 view 過程發現 wiki 缺口或矛盾，回報並建議走 jdn-kb-intake／jdn-kb-organize 修正，而不是在 view 裡偷偷補。
3. `video` 涉及外部付費 API（如 TTS）時，先告知成本並取得同意；不得在檔案中寫入 API 金鑰。
