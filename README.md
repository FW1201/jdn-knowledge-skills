# jdn-knowledge-skills

> JDN LLM Wiki 知識管理 Skills 套件 — 入庫、整理、查詢、管理，完整知識庫工作流

**作者**：FW1201（Kevin Wu）  
**版本**：1.1.0  
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
| `jdn-kb-view` 🆕 | 理解格式層：簡明技術中文／結構圖／互動網頁／解說影片分鏡 | /wiki query --as、畫成圖、做成網頁、用簡單的話講 |

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

## v1.1：理解格式層（View Layer）

> 設計來源：Andrej Karpathy（2026-10-02）——LLM 做的事愈多，人的工作愈往上移到「理解 LLM 的輸出」。
> 依理解成本挑格式：受控文字 → 圖 → 互動網頁 → 解說影片。

**定位**：wiki 是持久知識層；view 是可拋棄、可重生的檢視層。log 記錄配方，不一定保存成品。

```
/wiki query 構式語法 --as ste       → 簡明技術中文答案
/wiki query 入庫流程 --as diagram   → Mermaid 流程圖
/wiki query 三種方法比較 --as html  → 互動比較頁（先過查證閘門）
/wiki query 對應分析 --as video     → 解說影片分鏡 JSON（交給影片 Skill 渲染）
/wiki query … --as auto             → 自動選格式，預設往低階選
```

| 變更 | 內容 |
|---|---|
| 新增 `jdn-kb-view` | 四階格式路由、查證閘門（每個 claim 回指 wiki 頁）、view 配方記錄 |
| 新增 `jdn-kb-view/references/plain-zh-style.md` | 簡明技術中文規範（借 ASD-STE100 精神，非翻譯） |
| `jdn-kb-query` 1.1.0 | 新增 `--as` 參數；view 成品不觸發存回 |
| `jdn-kb-intake` 1.1.0 | 新增 Phase 3b 理解層：頁首 TL;DR；synthesis/concept 附結構圖 |

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

## 規格對齊（JDN LLM Wiki v1.0）

| Skill | 對應規格章節 |
|-------|------------|
| `jdn-kb-intake` | §5.1 `/wiki ingest` workflow |
| `jdn-kb-query` | §5.2 `/wiki query` workflow |
| `jdn-kb-view` | §5.2 輸出格式延伸（v1.1） |
| `jdn-kb-organize` | §5.3 `/wiki lint` + §5.4 `/wiki status` |
| `jdn-kb-management` | §5.4 `/wiki status` + §10 Agent Replication Checklist |
| JDN- frontmatter | §4.1 Frontmatter Specification |
| log.md 格式 | `## [YYYY-MM-DD] {op} \| {desc}` |

規格來源：[FW1201/jdn-llm-wiki](https://github.com/FW1201/jdn-llm-wiki)

> Skills augment the wiki system — they provide role-specific workflows that PRODUCE content that then gets ingested into the wiki. *(Appendix B)*

---

## 授權

MIT License — 歡迎 Fork 和 PR

---

*最後更新：2026-10-03（v1.1.0 理解格式層）*
