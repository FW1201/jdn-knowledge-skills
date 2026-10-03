#!/bin/bash
# jdn-knowledge-skills 安裝腳本
set -e

SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== jdn-knowledge-skills 安裝 ==="
echo "安裝目標：$SKILLS_DIR"

mkdir -p "$SKILLS_DIR"

for skill in jdn-kb-intake jdn-kb-organize jdn-kb-query jdn-kb-management jdn-kb-view; do
  if [ -d "$REPO_DIR/$skill" ]; then
    echo "  安裝 $skill..."
    rm -rf "$SKILLS_DIR/$skill"
    cp -r "$REPO_DIR/$skill" "$SKILLS_DIR/$skill"
    echo "  ✓ $skill"
  fi
done

echo ""
echo "安裝完成！可用指令："
echo "  /wiki ingest   → 知識入庫"
echo "  /wiki lint     → 知識庫診斷"
echo "  /wiki query    → 查詢知識庫"
echo "  /wiki status   → 系統狀態報告"
echo "  /wiki query … --as ste|diagram|html|video|auto → 理解格式層"
