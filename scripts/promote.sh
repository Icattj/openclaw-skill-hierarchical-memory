#!/bin/bash
# promote.sh — Show promotion status and readiness
# Usage: bash promote.sh

MEMORY_DIR="$HOME/.openclaw/workspace/memory"
EVAL_DIR="$MEMORY_DIR/evaluations"
LESSONS_FILE="$MEMORY_DIR/lessons.json"
MEMORY_MD="$HOME/.openclaw/workspace/MEMORY.md"

echo "═══════════════════════════════════"
echo "  Knowledge Promotion Status"
echo "═══════════════════════════════════"

# L0 → L1 status
echo ""
echo "📊 L0 → L1 (Evaluate)"
RECENT_EVALS=0
for i in $(seq 0 6); do
    DATE=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null || date -v-${i}d +%Y-%m-%d 2>/dev/null)
    if [ -f "$EVAL_DIR/$DATE.json" ] && command -v jq &>/dev/null; then
        COUNT=$(jq 'length' "$EVAL_DIR/$DATE.json" 2>/dev/null || echo 0)
        RECENT_EVALS=$((RECENT_EVALS + COUNT))
    fi
done
echo "   Evaluations (last 7 days): $RECENT_EVALS"
if [ "$RECENT_EVALS" -lt 3 ]; then
    echo "   ⚠️  Low evaluation count — consider evaluating recent tasks"
else
    echo "   ✅ Sufficient evaluations for promotion"
fi

# L1 → L2 status
echo ""
echo "📚 L1 → L2 (Extract Lessons)"
if [ -f "$LESSONS_FILE" ] && command -v jq &>/dev/null; then
    ACTIVE=$(jq '[.[] | select(.status=="active")] | length' "$LESSONS_FILE" 2>/dev/null || echo 0)
    PRUNED=$(jq '[.[] | select(.status=="pruned")] | length' "$LESSONS_FILE" 2>/dev/null || echo 0)
    PROMOTED=$(jq '[.[] | select(.status=="promoted")] | length' "$LESSONS_FILE" 2>/dev/null || echo 0)
    echo "   Active lessons: $ACTIVE"
    echo "   Pruned: $PRUNED"
    echo "   Promoted to L3: $PROMOTED"
    
    if [ "$RECENT_EVALS" -ge 10 ]; then
        echo "   🔔 $RECENT_EVALS un-promoted evaluations — run 'Extract lessons'"
    fi
else
    echo "   No lessons.json found (run evaluate.sh --init)"
fi

# L2 → L3 status
echo ""
echo "🧠 L2 → L3 (Update Insights)"
if [ -f "$LESSONS_FILE" ] && command -v jq &>/dev/null; then
    HIGH_CONF=$(jq '[.[] | select(.status=="active" and .confidence > 0.8)] | length' "$LESSONS_FILE" 2>/dev/null || echo 0)
    echo "   Lessons ready for promotion (conf > 0.8): $HIGH_CONF"
    if [ "$HIGH_CONF" -gt 0 ]; then
        echo "   🔔 $HIGH_CONF lessons ready — run 'Update insights'"
    fi
fi

if [ -f "$MEMORY_MD" ]; then
    LINES=$(wc -l < "$MEMORY_MD")
    echo "   MEMORY.md: $LINES lines"
    if [ "$LINES" -gt 200 ]; then
        echo "   ⚠️  MEMORY.md over 200 lines — consider pruning"
    fi
fi

echo ""
echo "═══════════════════════════════════"
