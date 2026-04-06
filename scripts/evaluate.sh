#!/bin/bash
# evaluate.sh — Helper for creating L1 evaluations
# Usage: 
#   bash evaluate.sh --init          (bootstrap memory directories)
#   bash evaluate.sh --status        (show evaluation stats)

MEMORY_DIR="$HOME/.openclaw/workspace/memory"
EVAL_DIR="$MEMORY_DIR/evaluations"
ARCHIVE_DIR="$EVAL_DIR/archive"
COUNTER_FILE="$EVAL_DIR/.counter"

case "$1" in
    --init)
        echo "Bootstrapping hierarchical memory..."
        mkdir -p "$EVAL_DIR" "$ARCHIVE_DIR" "$MEMORY_DIR/archive"
        [ -f "$MEMORY_DIR/lessons.json" ] || echo '[]' > "$MEMORY_DIR/lessons.json"
        [ -f "$COUNTER_FILE" ] || echo '0' > "$COUNTER_FILE"
        echo "✅ Created:"
        echo "   $EVAL_DIR/"
        echo "   $ARCHIVE_DIR/"
        echo "   $MEMORY_DIR/archive/"
        echo "   $MEMORY_DIR/lessons.json"
        echo "   $COUNTER_FILE"
        ;;
    --status)
        echo "═══════════════════════════════"
        echo "  L1 Evaluation Status"
        echo "═══════════════════════════════"
        
        if [ -f "$COUNTER_FILE" ]; then
            COUNTER=$(cat "$COUNTER_FILE")
            echo "  Total evaluations created: $COUNTER"
        else
            echo "  Counter not initialized (run --init)"
        fi
        
        TODAY=$(date +%Y-%m-%d)
        WEEK_AGO=$(date -d "7 days ago" +%Y-%m-%d 2>/dev/null || date -v-7d +%Y-%m-%d 2>/dev/null)
        
        EVAL_FILES=$(find "$EVAL_DIR" -maxdepth 1 -name "*.json" 2>/dev/null | wc -l)
        echo "  Evaluation files: $EVAL_FILES"
        
        if [ -f "$EVAL_DIR/$TODAY.json" ] && command -v jq &>/dev/null; then
            TODAY_COUNT=$(jq 'length' "$EVAL_DIR/$TODAY.json" 2>/dev/null || echo 0)
            echo "  Today's evaluations: $TODAY_COUNT"
        fi
        
        ARCHIVE_FILES=$(find "$ARCHIVE_DIR" -name "*.json" 2>/dev/null | wc -l)
        echo "  Archived months: $ARCHIVE_FILES"
        
        echo "═══════════════════════════════"
        ;;
    *)
        echo "Usage:"
        echo "  bash evaluate.sh --init     Bootstrap memory directories"
        echo "  bash evaluate.sh --status   Show evaluation statistics"
        echo ""
        echo "To create evaluations, use the agent command:"
        echo "  'Evaluate last task'"
        echo "  'Evaluate: <description>'"
        ;;
esac
