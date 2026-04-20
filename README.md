# jdn-knowledge-skills

> JDN LLM Wiki 知識管理 Skills 套件 — 入庫、整理、查詢、管理，完整知識庫工作流

**作者**：FW1201（Kevin Wu）  
**版本**：1.0.0  
**規格基準**：JDN LLM Wiki v1.0（`JDN_llm_wiki.md`）  
**適用平台**：Claude Code CLI

---

## Skills 清單

| Skill | 說明 | 觸發詞 |
|-------|------|--------|
| `jdn-kb-intake` | 讀取 raw/ 素材 → 生成 wiki 頁面 | /wiki ingest、入庫、新素材入庫 |
| `jdn-kb-organize` | 掃描 wiki/，修復連結與 frontmatter | /wiki lint、整理知識庫、修復連結 |
| `jdn-kb-query` | 自然語言查詢 wiki 頁面 | /wiki query、查詢知識庫、wiki 裡找 |
| `jdn-kb-management` | 統計報告、初始化、歸檔 | /wiki status、知識庫健診、盤點 |

---

## 安裝

```bash
npx skills add FW1201/jdn-knowledge-skills --all -a claude-code
```

或手動安裝單一 Skill：

```bash
npx skills add FW1201/jdn-knowledge-skills/jdn-kb-intake -a claude-code
```

---

## 快速上手

### 新知識庫初始化

```
/wiki status          → 查看目前狀態（或初始化新知識庫）
```

### 日常入庫流程

```
raw/ 放入新素材
→ /wiki ingest        → 掃描新檔案，生成 wiki 頁面
```

### 定期整理

```
/wiki lint            → 診斷問題（孤立頁面、斷裂連結）
整理知識庫            → 修復全部問題
```

### 查詢

```
/wiki query 構式語法  → 搜尋相關頁面，綜合回答
wiki 裡有關 AI 教育的筆記？
```

---

## JDN- Frontmatter 規格

所有 wiki 頁面必須使用 JDN- 前綴欄位：

```yaml
---
JDN-title: "頁面標題"
JDN-role: researcher        # editor|researcher|teacher|developer|admin|learner|cross-role
JDN-type: source-summary    # source-summary|entity|concept|synthesis|profile|index
JDN-sources:
  - raw/{角色}/{檔名}
JDN-created: 2026-04-20
JDN-updated: 2026-04-20
JDN-links: []
JDN-tags: []
---
```

---

## 相關資源

- [JDN LLM Wiki 規格（英文）](https://github.com/FW1201/jdn-llm-wiki)
- 本 Repo 是 JDN LLM Wiki 規格的官方 Skills 實作

---

## 授權

MIT License — 歡迎 Fork 和 PR

---

*最後更新：2026-04-20*
