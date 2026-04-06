---
name: hierarchical-memory
description: Four-level memory system (DIKW pyramid) with automatic knowledge refinement. L0 History → L1 Evaluations → L2 Lessons → L3 Insights. Includes hot/warm/cold tiers, automatic promotion rules, and cross-level search. Use after completing tasks (evaluate), periodically (promote lessons), or when recalling context (cross-level search).
---

# Hierarchical Memory System

A 4-level memory architecture based on the DIKW (Data → Information → Knowledge → Wisdom) pyramid. Replaces flat-file memory with structured knowledge refinement that automatically promotes raw observations into actionable lessons and strategic insights.

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│  L3 — INSIGHTS (Wisdom)                     │  MEMORY.md
│  Strategic truths, user preferences,        │  Always loaded
│  cross-domain decision patterns             │  Monthly promotion
├─────────────────────────────────────────────┤
│  L2 — LESSONS (Knowledge)                   │  memory/lessons.json
│  Proven patterns with evidence              │  Weekly promotion
│  Actionable rules, confidence scores        │  Searchable
├─────────────────────────────────────────────┤
│  L1 — EVALUATIONS (Information)             │  memory/evaluations/YYYY-MM-DD.json
│  Task assessments: what worked/failed       │  After each significant task
│  Quality scores, timing, tags               │  Last 30 days warm
├─────────────────────────────────────────────┤
│  L0 — HISTORY (Data)                        │  memory/YYYY-MM-DD.md
│  Raw daily logs: conversations,             │  Already exists
│  decisions, tool outputs                    │  Last 3 days hot
└─────────────────────────────────────────────┘
```

## Memory Levels

### L0 — History (Data)

**Location:** `memory/YYYY-MM-DD.md`
**Purpose:** Raw chronological log of everything that happened.
**Already exists** — no structural changes needed. Just formalize the format:

```markdown
# YYYY-MM-DD

## HH:MM — [Event Type]
Brief description of what happened.
- Key details
- Decisions made
- Outcomes

## HH:MM — [Event Type]
...
```

**Event types:** `Task`, `Decision`, `Conversation`, `Error`, `Deploy`, `Discovery`, `Escalation`

### L1 — Evaluations (Information)

**Location:** `memory/evaluations/YYYY-MM-DD.json`
**Purpose:** Structured assessment of completed tasks — what worked, what didn't, quality scores.
**Created:** After every significant task completion (manual or automatic).

Each evaluation captures:
- **What** was done (task description)
- **How well** it went (quality 1-5)
- **How long** it took vs expected
- **What worked** and **what failed**
- **Domain** and **tags** for cross-referencing
- **References** back to L0 entries

See `references/schemas.md` for the full JSON schema.

### L2 — Lessons & Rules (Knowledge)

**Location:** `memory/lessons.json` + `memory/rules.md`
**Purpose:** Two types of knowledge, inspired by Anton's memory architecture:

**Lessons** (`lessons.json`) — Factual patterns extracted from evaluations. Things learned from experience.
- "Sub-agents timeout on complex generation tasks"
- "OCR accuracy drops on handwritten invoices"
- Each has evidence, confidence, and actionable rule

**Rules** (`rules.md`) — Behavioral directives. Always/never/when rules that govern how the agent acts.
- "Always use --no-verification with TruffleHog"
- "Never share /council URL"  
- "When someone asks for access, confirm with Lucy first"

**Created:** Lessons promoted when pattern appears 3+ times in L1. Rules extracted from explicit corrections or standing instructions.

A lesson answers: **"What did I learn?"**
A rule answers: **"What must I always/never do?"**

### L3 — Insights (Wisdom)

**Location:** `MEMORY.md` (workspace root)
**Purpose:** High-level strategic truths, decision patterns, and user preferences. Loaded every session.
**Created:** When L2 lessons prove consistently true (confidence > 0.8, cross-domain applicability). Monthly promotion or on-demand.

MEMORY.md is the distilled wisdom layer. Keep it lean. If it grows past ~200 lines, prune aggressively — only the most durable, cross-cutting insights belong here.

---

## Knowledge Refinement (Promotion Rules)

Knowledge flows upward through structured promotion. Each level filters and compresses the level below it. See `references/promotion-rules.md` for detailed rules.

### L0 → L1: Evaluate (After significant tasks)

**Trigger:** After completing any significant task — skill builds, deployments, debugging sessions, outreach campaigns, pipeline runs.
**Process:**

1. Read today's L0 entries (or the entries related to the task)
2. Identify the task boundaries (start/end)
3. Assess quality, timing, what worked, what failed
4. Write structured evaluation to `memory/evaluations/YYYY-MM-DD.json`
5. Auto-increment the evaluation ID (`eval-NNN` where NNN is global counter)

**How to run:**
```
"Evaluate last task"
```

Or with details:
```
"Evaluate: Built the hierarchical memory skill. Took about 45 minutes, expected 60. 
Decomposition was clean but schemas needed a second pass."
```

**Agent procedure:**

```
1. Determine today's date → YYYY-MM-DD
2. Read memory/YYYY-MM-DD.md for context
3. If evaluations file exists, read it; otherwise start with []
4. Determine next eval ID:
   - Read memory/evaluations/.counter (if exists) → increment
   - Otherwise scan existing files for highest eval-NNN → increment
   - Write new counter to memory/evaluations/.counter
5. Construct evaluation object (see schema in references/schemas.md)
6. Append to the day's evaluations array
7. Write updated JSON to memory/evaluations/YYYY-MM-DD.json
8. Confirm: "L1 evaluation [eval-NNN] recorded for: {task summary}"
```

### L1 → L2: Extract Lessons (Weekly or on-demand)

**Trigger:** Weekly (Sunday heartbeat/cron), or manual `"Extract lessons"` command.
**Process:**

1. Read all L1 evaluations from the last 7 days (or specified range)
2. Group by domain and tags
3. Identify patterns that appear 3+ times:
   - Same type of failure across tasks
   - Same success pattern across domains
   - Consistent timing over/underestimates
   - Recurring tool/approach preferences
4. For each pattern:
   - If lesson already exists in `memory/lessons.json` → update evidence, bump occurrences, recalculate confidence
   - If new → create lesson with confidence = occurrences / total_evals_in_domain
5. Write updated `memory/lessons.json`
6. Report: "Promoted N new lessons, updated M existing. Top lesson: {pattern}"

**Confidence calculation:**
```
confidence = min(0.95, occurrences / (occurrences + 3))
```
This uses a Bayesian-like smoothing: 3 occurrences → 0.50, 5 → 0.63, 10 → 0.77, 20 → 0.87.

**How to run:**
```
"Extract lessons"
"Extract lessons from last 14 days"
```

**Agent procedure:**

```
1. Determine date range (default: last 7 days)
2. Read all memory/evaluations/YYYY-MM-DD.json files in range
3. Collect all evaluations into a flat list
4. Read existing memory/lessons.json (or start with [])
5. For each evaluation, extract:
   - what_worked items → potential positive patterns
   - what_failed items → potential negative patterns
   - domain + tags → grouping keys
6. Group similar items (fuzzy match on descriptions)
7. For groups with 3+ items:
   a. Check if matching lesson exists (by pattern similarity)
   b. If exists: add new evidence refs, increment occurrences, 
      update last_seen, recalculate confidence
   c. If new: create lesson object with:
      - id: lesson-NNN (increment from highest existing)
      - pattern: descriptive summary of the repeated observation
      - evidence: list of eval IDs
      - first_seen / last_seen dates
      - occurrences count
      - confidence: calculated per formula
      - domain: most common domain in evidence
      - actionable_rule: concrete "do this instead" instruction
      - status: "active"
8. Write updated memory/lessons.json
9. Report summary
```

### L2 → L3: Update Insights (Monthly or on-demand)

**Trigger:** Monthly (first Sunday of month), or manual `"Update insights"` command.
**Process:**

1. Read all lessons from `memory/lessons.json`
2. Filter for high-confidence lessons (confidence > 0.8)
3. Group by domain — look for cross-domain patterns
4. For each insight candidate:
   - Does it represent a durable truth (not just a phase)?
   - Is it actionable at a strategic level?
   - Does it affect multiple agents or domains?
5. Read current `MEMORY.md`
6. Add new insights under a `## Lessons Learned` section (or update existing)
7. Remove any MEMORY.md entries that are contradicted by new evidence
8. Write updated `MEMORY.md`
9. Report: "Promoted N insights to MEMORY.md. Removed M outdated entries."

**How to run:**
```
"Update insights"
```

**Agent procedure:**

```
1. Read memory/lessons.json
2. Filter: confidence > 0.8 AND status == "active" AND occurrences >= 5
3. Read MEMORY.md
4. For each qualifying lesson:
   a. Check if similar insight already exists in MEMORY.md
   b. If exists: update wording if lesson has stronger evidence
   c. If new: draft concise insight statement
5. Also check for MEMORY.md entries that should be pruned:
   - Contradicted by recent lessons
   - No longer relevant (referenced project completed, etc.)
6. Write updated MEMORY.md
7. Report changes
```

---

## Knowledge Retrieval (Cross-Level Search)

When you need context on a topic, drill down through the levels:

### "What do I know about X?"

**Agent procedure:**

```
1. Search L3 (MEMORY.md):
   - grep/search for X in MEMORY.md
   - Report any matching insights
   
2. Search L2 (lessons.json):
   - Filter lessons where domain, pattern, actionable_rule, or tags contain X
   - Report matching lessons with confidence scores
   
3. Search L1 (evaluations):
   - Search recent evaluations (last 30 days) for X in task, tags, 
     what_worked, what_failed
   - Report matching evaluations
   
4. Search L0 (daily files) — only if L1-L3 didn't provide enough:
   - grep through memory/YYYY-MM-DD.md files for X
   - Report matching entries with dates

5. Synthesize:
   - Combine findings from all levels
   - Present highest-confidence information first
   - Note any contradictions between levels
```

**How to run:**
```
"What do I know about OCR?"
"What do I know about skill building?"
"Memory search: bookkeeper outreach"
```

---

## Hot / Warm / Cold Tiers

### 🔴 Hot (Always in Context)

These are loaded at session start or always available:

| Data | Level | Location |
|------|-------|----------|
| Strategic insights | L3 | `MEMORY.md` |
| Last 3 days of logs | L0 | `memory/YYYY-MM-DD.md` |
| Top 10 lessons | L2 | `memory/lessons.json` (sorted by occurrences × confidence) |

**To get top 10 lessons for context loading:**
```bash
# Use the memory-status.sh script or:
cat memory/lessons.json | jq '[.[] | select(.status=="active")] | sort_by(-(.occurrences * .confidence)) | .[0:10]'
```

### 🟡 Warm (Searchable, Loaded on Demand)

| Data | Level | Location |
|------|-------|----------|
| Full lessons database | L2 | `memory/lessons.json` |
| Last 30 days evaluations | L1 | `memory/evaluations/YYYY-MM-DD.json` |
| Daily files 4-30 days old | L0 | `memory/YYYY-MM-DD.md` |

Access via cross-level search or direct file read.

### 🔵 Cold (Archived, Rarely Accessed)

| Data | Level | Archival Rule |
|------|-------|---------------|
| Evaluations > 30 days | L1 | Compress to `memory/evaluations/archive/YYYY-MM-summary.json` |
| Daily files > 90 days | L0 | Move to `memory/archive/YYYY-MM/` |
| Lessons confidence < 0.3 | L2 | Set status to `"pruned"`, remove from active queries |

### Memory Cleanup

**How to run:**
```
"Memory cleanup"
```

**Agent procedure:**

```
1. Identify today's date

2. Archive old evaluations (L1):
   - Find all evaluations/YYYY-MM-DD.json files older than 30 days
   - Group by month
   - For each month, create summary:
     - Total evaluations
     - Average quality score
     - Most common domains/tags
     - Key patterns (what_worked/what_failed frequency)
   - Write to memory/evaluations/archive/YYYY-MM-summary.json
   - Delete (or move) individual daily files

3. Archive old daily files (L0):
   - Find all memory/YYYY-MM-DD.md files older than 90 days
   - Move to memory/archive/YYYY-MM/
   - Create index: memory/archive/YYYY-MM/INDEX.md with dates and summaries

4. Prune weak lessons (L2):
   - In lessons.json, set status="pruned" for lessons where:
     - confidence < 0.3 AND last_seen > 60 days ago
     - occurrences == 1 AND first_seen > 30 days ago (never reinforced)
   
5. Report:
   - Evaluations archived: N files → M monthly summaries
   - Daily files archived: N files
   - Lessons pruned: N
   - Total storage freed: approximate size
```

---

## Memory Status

**How to run:**
```
"Memory status"
```

**Agent procedure:**

```
1. Count files at each level:
   - L0: count memory/YYYY-MM-DD.md files
   - L1: count evaluation files + total evaluation entries
   - L2: count active lessons in lessons.json
   - L3: line count of MEMORY.md

2. Check last promotion dates:
   - Last L0→L1: most recent evaluation timestamp
   - Last L1→L2: read memory/lessons.json metadata or last_seen dates
   - Last L2→L3: check MEMORY.md modification date

3. Storage sizes:
   - du -sh memory/ (total)
   - du -sh memory/evaluations/ (L1)
   - wc -c memory/lessons.json (L2)

4. Health indicators:
   - ⚠️ No evaluations in last 7 days → "L1 stale — run 'Evaluate last task'"
   - ⚠️ No lesson promotion in 14 days → "L2 stale — run 'Extract lessons'"
   - ⚠️ MEMORY.md not updated in 30 days → "L3 stale — run 'Update insights'"
   - ⚠️ Evaluations > 30 days not archived → "Run 'Memory cleanup'"
   - ✅ All levels healthy

5. Display formatted report
```

**Example output:**
```
📊 Hierarchical Memory Status
═══════════════════════════════
Level    │ Count  │ Last Updated │ Storage
─────────┼────────┼──────────────┼────────
L0 Data  │ 47 files │ Today       │ 128 KB
L1 Info  │ 23 evals │ Yesterday   │  12 KB
L2 Know  │  8 active│ 3 days ago  │   4 KB
L3 Wise  │ 85 lines │ 2 weeks ago │   6 KB
─────────┼────────┼──────────────┼────────
Archive  │ 12 files │ Last Sunday │  34 KB
═══════════════════════════════
Health: ⚠️ L3 stale — consider running 'Update insights'
```

---

## Integration Points

### Pipeline Orchestrator Integration

After any pipeline completes its VERIFY stage, automatically trigger L0→L1:

```
Pipeline VERIFY complete → Read pipeline output → Create L1 evaluation
```

The pipeline orchestrator should call:
```
"Evaluate: {pipeline_name} pipeline completed. Quality: {pass/fail}. Duration: {N} minutes."
```

### Heartbeat Integration

Add to `HEARTBEAT.md`:
```markdown
### Memory Maintenance
- If >3 days since last L1→L2 promotion: run "Extract lessons"
- If >7 days since last evaluation: flag "Memory going stale"
```

### Cron Integration

Recommended cron jobs:
- **Weekly (Sunday):** `"Extract lessons from last 7 days"` — L1→L2 promotion
- **Monthly (1st Sunday):** `"Update insights"` — L2→L3 promotion
- **Monthly (1st Sunday):** `"Memory cleanup"` — archive cold data

### Agent Query Integration

Any agent can use the cross-level search:
```
"What do I know about {topic}?"
```

This searches all levels and returns synthesized context. Useful before starting any significant task.

---

## Quick Reference

| Command | What It Does | Frequency |
|---------|-------------|-----------|
| `Evaluate last task` | Creates L1 evaluation | After significant tasks |
| `Evaluate: {details}` | Creates L1 with provided context | After tasks (with detail) |
| `Extract lessons` | L1→L2 promotion | Weekly |
| `Update insights` | L2→L3 promotion | Monthly |
| `Memory status` | Dashboard of all levels | Anytime |
| `What do I know about X` | Cross-level search | Before tasks |
| `Memory cleanup` | Archive cold data | Monthly |

---

## File Structure

```
~/.openclaw/workspace/
├── MEMORY.md                          ← L3 (Wisdom/Insights)
├── memory/
│   ├── YYYY-MM-DD.md                  ← L0 (History/Data)
│   ├── evaluations/
│   │   ├── .counter                   ← Global eval ID counter
│   │   ├── YYYY-MM-DD.json           ← L1 (Evaluations/Information)
│   │   └── archive/
│   │       └── YYYY-MM-summary.json   ← Cold L1 summaries
│   ├── lessons.json                   ← L2 (Lessons/Knowledge)
│   └── archive/
│       └── YYYY-MM/                   ← Cold L0 daily files
│           ├── INDEX.md
│           └── YYYY-MM-DD.md
└── skills/hierarchical-memory/
    ├── SKILL.md                       ← This file
    ├── references/
    │   ├── dikw-model.md
    │   ├── promotion-rules.md
    │   └── schemas.md
    └── scripts/
        ├── evaluate.sh
        ├── promote.sh
        └── memory-status.sh
```

---

## Bootstrap (First Run)

If the memory hierarchy doesn't exist yet, create it:

```bash
mkdir -p memory/evaluations/archive memory/archive
# Initialize lessons.json if it doesn't exist
[ -f memory/lessons.json ] || echo '[]' > memory/lessons.json
# Initialize eval counter if it doesn't exist  
[ -f memory/evaluations/.counter ] || echo '0' > memory/evaluations/.counter
```

Or run:
```bash
bash skills/hierarchical-memory/scripts/evaluate.sh --init
```

---

## Design Principles

1. **Upward compression.** Each level is smaller and more valuable than the level below. L0 is noisy and large. L3 is concise and durable.
2. **Evidence-based promotion.** Nothing moves up without evidence. Lessons need 3+ evaluations. Insights need high confidence.
3. **Graceful degradation.** If lessons.json doesn't exist, the system still works — just without L2. Each level is independently useful.
4. **Contradiction resolution.** New evidence can demote or prune old lessons. Confidence decays if a pattern stops appearing.
5. **Human-in-the-loop.** Automatic promotion generates drafts. The agent reviews before writing. No silent MEMORY.md rewrites.
