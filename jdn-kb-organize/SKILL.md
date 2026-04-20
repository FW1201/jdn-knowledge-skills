---
name: jdn-kb-organize
description: >
  JDN LLM Wiki 知識整理 Skill。
  當使用者說「整理知識庫」「修復連結」「掃描孤立頁面」「重新整理 wiki」
  「知識庫健診」「lint」「找到缺失的連結」時觸發。
  掃描 wiki/ 目錄，修復孤立頁面、補充雙向連結、
  統一 JDN- frontmatter 格式，並更新 wiki/index.md。
version: 1.0.0
---

# JDN KB Organize — 知識整理

掃描 wiki/ 並修復結構問題，讓知識庫保持健康可導航。

## 前置條件

先讀取：
1. `WIKI.md` — 系統規格
2. `wiki/index.md` — 現有頁面清單

---

## 工作流程

### Phase 1：掃描並診斷

掃描所有 `wiki/**/*.md`（排除 index.md、log.md），檢查以下問題：

#### 1-A Frontmatter 合規性
對每個頁面驗證：
- 是否有所有必要的 JDN- 欄位（title、role、type、sources、created、updated、links、tags）
- `JDN-role` 值是否在合法集合內
- `JDN-type` 值是否在合法集合內
- `JDN-updated` 是否為 ISO 日期格式

#### 1-B 孤立頁面
找出沒有任何其他頁面連結到的頁面（`JDN-links` 中未被引用）

#### 1-C 斷裂連結
找出 `JDN-links` 中指向不存在頁面的路徑

#### 1-D 雙向連結缺漏
找出 A 的 `JDN-links` 有 B，但 B 的 `JDN-links` 沒有 A 的情況

#### 1-E Index 不同步
找出 wiki/ 中有頁面但 index.md 沒有登錄，或 index.md 有條目但頁面不存在

### Phase 2：輸出診斷報告

以清單格式輸出問題，讓使用者確認修復範圍：

```
📊 JDN KB 診斷報告 — {日期}

Frontmatter 問題（{n} 頁）：
  ⚠ wiki/researcher/paper-foo.md — 缺少 JDN-type

孤立頁面（{n} 頁）：
  🔴 wiki/cross-role/old-topic.md — 無任何頁面連結此頁

斷裂連結（{n} 個）：
  🔴 wiki/editor/article.md → wiki/researcher/nonexistent.md（目標不存在）

雙向連結缺漏（{n} 對）：
  🟡 wiki/teacher/lesson.md → wiki/researcher/method.md（反向連結缺漏）

Index 不同步（{n} 頁）：
  🟡 wiki/admin/procedure.md — 頁面存在但未在 index.md 登錄

→ 是否要我修復全部問題？（或說「只修 X 類」）
```

### Phase 3：執行修復

根據使用者確認，逐項修復：

**修復 Frontmatter**：補全缺少的欄位（`JDN-type` 用 `source-summary` 預設值，`JDN-tags` 用 `[]`）

**處理孤立頁面**：
- 若有相關頁面，補上雙向連結
- 若確認廢棄，移至 `archive/`（不刪除）

**修復斷裂連結**：
- 移除或更正 `JDN-links` 中無效的路徑

**補全雙向連結**：
- 在 B 的 `JDN-links` 中加入 A 的路徑

**同步 Index**：
- 補登缺漏的頁面條目
- 移除已不存在的條目

### Phase 4：更新日誌

```
YYYY-MM-DD HH:MM | organize | 修復 {n} 項問題 | frontmatter:{a} 孤立:{b} 連結:{c} index:{d}
```

---

## 快速指令對照

| 使用者說 | 執行範圍 |
|---------|---------|
| `/wiki lint` | Phase 1-2（只診斷，不修復） |
| `修復全部` | Phase 1-3 完整執行 |
| `只修連結` | Phase 1 + 僅執行 Phase 3 的連結修復 |
| `清理孤立頁面` | Phase 1 + 僅處理孤立頁面 |

---

## 注意事項

1. 修復前一定要先輸出診斷報告，等使用者確認
2. 永遠不要刪除頁面——廢棄的移到 `archive/`
3. 補全 frontmatter 時用合理預設值，不要憑空捏造內容
4. 每次修復後更新 `JDN-updated` 為今天日期
