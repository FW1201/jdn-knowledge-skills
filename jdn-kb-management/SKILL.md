---
name: jdn-kb-management
description: >
  JDN LLM Wiki 知識庫管理 Skill。
  當使用者說「知識庫管理」「wiki 系統健診」「顯示 wiki 統計」
  「盤點知識庫」「/wiki status」「設定 wiki 結構」「初始化知識庫」時觸發。
  執行系統級管理操作：統計報告、結構初始化、角色設定、歸檔管理。
version: 1.0.0
---

# JDN KB Management — 知識庫管理

系統級管理操作：初始化、統計、設定、歸檔。

---

## 操作清單

### 1. 系統狀態報告（/wiki status）

輸出以下統計：

```
📊 JDN KB 狀態報告 — {日期}

知識庫根目錄：{PROJECT_ROOT}
Wiki 規格版本：{WIKI.md 版本，若存在}

頁面統計：
  總頁面數：{n}
  按角色分布：
    editor:      {n} 頁
    researcher:  {n} 頁
    teacher:     {n} 頁
    developer:   {n} 頁
    admin:       {n} 頁
    cross-role:  {n} 頁

按類型分布：
  source-summary: {n}
  entity:         {n}
  concept:        {n}
  synthesis:      {n}
  profile:        {n}
  index:          {n}

原始素材：
  raw/ 檔案數：{n}
  已入庫：{n}
  待入庫：{n}

健康指標：
  Frontmatter 合規率：{%}
  孤立頁面數：{n}
  斷裂連結數：{n}

最近操作（log.md 最後 5 筆）：
  {log 條目}
```

---

### 2. 初始化新知識庫

若 `wiki/` 目錄不存在，建立基礎結構：

```bash
wiki/
├── index.md    # 主索引（空白模板）
├── log.md      # 操作日誌（空白，帶標題）
└── cross-role/ # 跨角色頁面目錄
```

同時詢問使用者：
- 要啟用哪些角色（預設：editor、researcher、teacher、developer、admin）
- 每個角色建立對應的 `wiki/{角色}/` 目錄

**WIKI.md 模板**（若不存在，提議建立）：

```markdown
# Wiki 規格文件
版本：1.0 | 建立日期：{今天}

## 角色命名空間
| 角色 | 目錄 | 觸發詞 |
|------|------|--------|
| editor | wiki/主編/ | 主編、圖卡、期刊 |
| researcher | wiki/研究者/ | 碩論、文獻、語料庫 |
| teacher | wiki/教師/ | 教案、課綱、試卷 |
| developer | wiki/開發者/ | Extension、Skills、GitHub |
| admin | wiki/行政/ | 公文、行政、簽呈 |

## JDN- 欄位規格
（詳見 jdn-kb-intake SKILL.md）
```

---

### 3. 歸檔管理

**列出可歸檔候選**：
- 180 天未更新（`JDN-updated` 超過半年）
- 孤立頁面（無任何連結）
- 使用者手動指定

**歸檔流程**：
1. 移動頁面到 `archive/{原路徑}`
2. 在原位置留下重定向殘根（可選）
3. 從 `wiki/index.md` 移除條目
4. 記錄 log：`YYYY-MM-DD | archive | {頁面路徑}`

---

### 4. 角色設定

查看或修改角色設定（對應 WIKI.md 或 CLAUDE.md 中的角色定義）：

```
目前角色設定：
  editor（主編）：wiki/主編/ | 觸發：主編、圖卡
  researcher（研究者）：wiki/研究者/ | 觸發：碩論、文獻

→ 要新增/修改/移除哪個角色？
```

---

### 5. 重建 Index

若 `wiki/index.md` 損壞或需要完整重建：

1. 掃描所有 `wiki/**/*.md`（排除 index.md、log.md）
2. 讀取每頁面的 frontmatter
3. 依角色分類，重新建立 index.md

**Index 格式規範**：
```markdown
# Wiki Index
最後更新：YYYY-MM-DD | 總頁數：{n}

## 主編（Editor）
- [頁面標題](wiki/主編/path.md) — 一行描述

## 研究者（Researcher）
- [頁面標題](wiki/研究者/path.md) — 一行描述

## 跨角色（Cross-Role）
- [頁面標題](wiki/cross-role/path.md) — 一行描述
```

---

## 注意事項

1. 狀態報告不修改任何檔案
2. 初始化只建立空白結構，不修改現有頁面
3. 歸檔前必須請使用者確認候選清單
4. 重建 index 是破壞性操作，執行前備份現有 index.md
