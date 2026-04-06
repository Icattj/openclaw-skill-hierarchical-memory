# Promotion Rules — Knowledge Refinement

Detailed rules for how knowledge moves between levels in the hierarchical memory system.

## Overview

```
L0 (Data) ──evaluate──▶ L1 (Information) ──extract──▶ L2 (Knowledge) ──distill──▶ L3 (Wisdom)
```

Each promotion:
1. Filters noise (not everything moves up)
2. Compresses (fewer items, more meaning)
3. Adds structure (raw → evaluated → patterned → principled)
4. Requires evidence (nothing promotes without proof)

---

## L0 → L1: Evaluate

### When to Trigger
- After completing any significant task (skill builds, deployments, bug fixes, outreach)
- After pipeline completion (VERIFY stage auto-triggers)
- After any session where meaningful work was done
- Manual: `"Evaluate last task"` or `"Evaluate: {description}"`

### What Qualifies as "Significant"
A task is significant if it:
- Took more than 15 minutes
- Produced a deliverable (file, deployment, message, decision)
- Involved a failure or unexpected outcome
- Was explicitly requested by Lucy
- Was a first-time attempt at something

Not significant (skip evaluation):
- Quick lookups or Q&A
- Routine heartbeat checks
- Simple file reads
- Status checks

### Evaluation Process
1. Identify the task boundaries in L0 (start timestamp → end timestamp)
2. Read the relevant L0 entries
3. Score quality (1-5):
   - 1: Failed, no useful output
   - 2: Partially completed, significant issues
   - 3: Completed with notable problems
   - 4: Completed well, minor issues
   - 5: Completed excellently, no issues
4. Estimate timing: actual vs expected minutes
5. Extract what_worked (list of positive observations)
6. Extract what_failed (list of negative observations)
7. Assign domain and tags
8. Write to `memory/evaluations/YYYY-MM-DD.json`

### Domain Taxonomy
Use consistent domain labels:
- `skill-building` — creating or updating skills
- `development` — code, infrastructure, deployment
- `outreach` — bookkeeper recruitment, communication
- `strategy` — planning, decision-making, analysis
- `operations` — server management, monitoring, maintenance
- `design` — UI/UX, visual, frontend
- `research` — investigating tools, markets, competitors
- `memory` — memory system itself, knowledge management

### Tag Conventions
Tags are freeform but aim for reusable terms:
- Technology: `python`, `node`, `bash`, `bedrock`, `ocr`
- Type: `bug-fix`, `feature`, `refactor`, `migration`, `testing`
- Agent: `michael`, `uriel`, `rafael`, etc.
- Project: `dataflow`, `magi`, `council`

---

## L1 → L2: Extract Lessons

### When to Trigger
- Weekly (Sunday via heartbeat or cron)
- Manual: `"Extract lessons"` or `"Extract lessons from last N days"`
- When L1 accumulates 10+ un-promoted evaluations

### Pattern Detection

A pattern is a repeated observation across evaluations. Detection methods:

**Keyword clustering:**
Group what_worked and what_failed items by similar keywords.
Example: If 3 evaluations mention "schema iteration" in what_failed, that's a pattern.

**Domain clustering:**
Look at evaluations in the same domain. If 4 out of 5 evaluations in "skill-building" mention "reference docs needed", that's a pattern.

**Timing patterns:**
If tasks consistently take 50%+ longer than estimated in a domain, that's a pattern.

**Quality patterns:**
If a specific type of task consistently scores 2-3, there's a systemic issue.

### Confidence Formula

```
confidence = min(0.95, occurrences / (occurrences + 3))
```

| Occurrences | Confidence |
|-------------|------------|
| 1 | 0.25 |
| 2 | 0.40 |
| 3 | 0.50 |
| 5 | 0.63 |
| 7 | 0.70 |
| 10 | 0.77 |
| 15 | 0.83 |
| 20 | 0.87 |
| 30 | 0.91 |

This uses additive smoothing (Laplace-like) to prevent premature certainty.

### Lesson Quality Criteria

Every lesson MUST have:
1. **Clear pattern statement** — what recurs
2. **Evidence** — list of evaluation IDs (minimum 3)
3. **Actionable rule** — "do X instead of Y" or "always do Z when W"
4. **Domain** — where this applies
5. **Confidence** — calculated, not guessed

Bad lessons (reject these):
- "Things sometimes don't work" — too vague
- "Be more careful" — not actionable
- Pattern with only 1-2 occurrences — not enough evidence
- Contradicted by more recent evidence — stale

### Updating Existing Lessons

When a new evaluation matches an existing lesson:
1. Add the evaluation ID to evidence list
2. Increment occurrences
3. Update last_seen date
4. Recalculate confidence
5. If the actionable_rule needs refinement based on new evidence, update it

### Confidence Decay (Future Enhancement)

If a lesson hasn't been reinforced (no new evidence) in 60+ days, its confidence should decay:
```
decayed_confidence = confidence * 0.9^(months_since_last_seen)
```
This ensures stale lessons gradually lose prominence.

---

## L2 → L3: Distill Insights

### When to Trigger
- Monthly (first Sunday of month)
- Manual: `"Update insights"`
- When a lesson reaches confidence > 0.9

### Promotion Criteria

A lesson becomes an insight when:
1. **High confidence** (> 0.8)
2. **Sufficient evidence** (5+ occurrences)
3. **Cross-domain applicability** (or deeply established in one domain)
4. **Durability** — the pattern has held over time (first_seen > 14 days ago)
5. **Actionable** — the rule can be stated in one sentence

### Insight Writing Style

Insights in MEMORY.md should be:
- **Concise:** One sentence per insight, maybe two if context is needed
- **Imperative:** "Always X when Y" or "Never Z without W"
- **Evidence-linked:** Optionally note source lesson ID

Example good insights:
```
- Complex skills need reference/ docs, not just SKILL.md (lesson-005, confidence 0.85)
- Schema design takes 30% longer than estimated — pad timelines accordingly
- Lucy wants results first, explanation after — lead with deliverables
```

Example bad insights:
```
- Things are complicated sometimes (too vague)
- Based on our comprehensive analysis of multiple evaluation cycles spanning
  several weeks... (too verbose)
```

### Contradiction Handling

When promoting to L3, check for contradictions:
1. Read current MEMORY.md entries
2. For each new insight, check if it contradicts an existing entry
3. If contradiction:
   - If new insight has higher confidence → replace old entry
   - If equal confidence → flag for human review
   - If lower confidence → skip promotion, note in log

### MEMORY.md Maintenance

During L2→L3 promotion, also:
- Remove entries that reference completed/cancelled projects (unless the lesson is universal)
- Update entries with new evidence if a stronger version exists
- Ensure total MEMORY.md stays under 200 lines (prune least-referenced entries)
- Keep a `## Lessons Learned` section separate from factual/context sections

---

## Cross-Level Demotion

Knowledge can move DOWN as well:

### L3 → L2 (Insight invalidated)
If new L1 evaluations consistently contradict an L3 insight:
1. Create counter-evidence in L2 (new lesson contradicting the insight)
2. When counter-lesson reaches confidence > 0.7, demote the L3 insight
3. Remove from MEMORY.md, add note to lesson explaining the demotion

### L2 → pruned (Lesson invalidated)
If a lesson's confidence drops below 0.3 (via decay or counter-evidence):
1. Set status to "pruned"
2. Keep in lessons.json for historical reference
3. Exclude from active queries and hot tier

---

## Promotion Scheduling Summary

| Promotion | Trigger | Frequency | Duration |
|-----------|---------|-----------|----------|
| L0→L1 | Task completion | Per-task | ~2 min |
| L1→L2 | Sunday heartbeat | Weekly | ~5 min |
| L2→L3 | 1st Sunday of month | Monthly | ~10 min |
| Cleanup | 1st Sunday of month | Monthly | ~5 min |
