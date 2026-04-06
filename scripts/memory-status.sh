#!/bin/bash
# memory-status.sh — Overview of the entire hierarchical memory system
# Usage: bash memory-status.sh

WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
EVAL_DIR="$MEMORY_DIR/evaluations"
LESSONS_FILE="$MEMORY_DIR/lessons.json"
MEMORY_MD="$WORKSPACE/MEMORY.md"

echo "📊 Hierarchical Memory Status"
echo "═══════════════════════════════════════════"
printf "%-10s │ %-10s │ %-14s │ %s\n" "Level" "Count" "Last Updated" "Storage"
echo "───────────┼────────────┼────────────────┼────────"

# L0 — History
L0_COUNT=$(find "$MEMORY_DIR" -maxdepth 1 -name "????-??-??.md" 2>/dev/null | wc -l | tr -d ' ')
L0_LATEST=$(ls -t "$MEMORY_DIR"/????-??-??.md 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/.md//' || echo "never")
L0_SIZE=$(du -sh "$MEMORY_DIR"/*.md 2>/dev/null | tail -1 | awk '{print $1}' || echo "0K")
L0_TOTAL=$(find "$MEMORY_DIR" -maxdepth 1 -name "????-??-??.md" -exec cat {} + 2>/dev/null | wc -c)
L0_SIZE_H=$(numfmt --to=iec $L0_TOTAL 2>/dev/null || echo "${L0_TOTAL}B")
printf "%-10s │ %10s │ %-14s │ %s\n" "L0 Data" "${L0_COUNT} files" "$L0_LATEST" "$L0_SIZE_H"

# L1 — Evaluations
L1_FILES=$(find "$EVAL_DIR" -maxdepth 1 -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
L1_COUNT=0
if command -v jq &>/dev/null; then
    for f in "$EVAL_DIR"/*.json; do
        [ -f "$f" ] && C=$(jq 'length' "$f" 2>/dev/null || echo 0) && L1_COUNT=$((L1_COUNT + C))
    done
fi
L1_LATEST=$(ls -t "$EVAL_DIR"/*.json 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/.json//' || echo "never")
L1_SIZE=$(du -sh "$EVAL_DIR" 2>/dev/null | awk '{print $1}' || echo "0K")
printf "%-10s │ %10s │ %-14s │ %s\n" "L1 Info" "${L1_COUNT} evals" "$L1_LATEST" "$L1_SIZE"

# L2 — Lessons
L2_COUNT=0
L2_UPDATED="never"
if [ -f "$LESSONS_FILE" ]; then
    if command -v jq &>/dev/null; then
        L2_COUNT=$(jq '[.[] | select(.status=="active")] | length' "$LESSONS_FILE" 2>/dev/null || echo 0)
        L2_UPDATED=$(stat -c %y "$LESSONS_FILE" 2>/dev/null | cut -d' ' -f1 || stat -f %Sm -t %Y-%m-%d "$LESSONS_FILE" 2>/dev/null || echo "unknown")
    fi
    L2_SIZE=$(du -h "$LESSONS_FILE" 2>/dev/null | awk '{print $1}' || echo "0K")
else
    L2_SIZE="0K"
fi
printf "%-10s │ %10s │ %-14s │ %s\n" "L2 Know" "${L2_COUNT} active" "$L2_UPDATED" "$L2_SIZE"

# L3 — Insights
L3_LINES=0
L3_UPDATED="never"
if [ -f "$MEMORY_MD" ]; then
    L3_LINES=$(wc -l < "$MEMORY_MD" | tr -d ' ')
    L3_UPDATED=$(stat -c %y "$MEMORY_MD" 2>/dev/null | cut -d' ' -f1 || stat -f %Sm -t %Y-%m-%d "$MEMORY_MD" 2>/dev/null || echo "unknown")
    L3_SIZE=$(du -h "$MEMORY_MD" 2>/dev/null | awk '{print $1}' || echo "0K")
else
    L3_SIZE="0K"
fi
printf "%-10s │ %10s │ %-14s │ %s\n" "L3 Wise" "${L3_LINES} lines" "$L3_UPDATED" "$L3_SIZE"

echo "═══════════════════════════════════════════"

# Health checks
echo ""
echo "Health:"
ISSUES=0

TODAY=$(date +%Y-%m-%d)
WEEK_AGO=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null || echo "")

if [ "$L1_COUNT" -eq 0 ]; then
    echo "  ⚠️  No evaluations yet — run 'Evaluate last task'"
    ISSUES=$((ISSUES + 1))
fi

if [ "$L2_COUNT" -eq 0 ] && [ "$L1_COUNT" -ge 3 ]; then
    echo "  ⚠️  Evaluations exist but no lessons extracted — run 'Extract lessons'"
    ISSUES=$((ISSUES + 1))
fi

if [ "$L3_LINES" -gt 200 ]; then
    echo "  ⚠️  MEMORY.md is $L3_LINES lines (target: <200) — consider pruning"
    ISSUES=$((ISSUES + 1))
fi

if [ "$ISSUES" -eq 0 ]; then
    echo "  ✅ All levels healthy"
fi
