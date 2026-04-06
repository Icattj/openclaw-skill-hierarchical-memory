# DIKW Model — The Four Levels of Knowledge

The DIKW pyramid (Data → Information → Knowledge → Wisdom) is a foundational model in knowledge management. It describes how raw observations get refined into actionable understanding through successive layers of processing.

## The Pyramid

```
        ╱╲
       ╱ W ╲        Wisdom (L3)      — Why it matters, what to do
      ╱─────╲
     ╱   K   ╲      Knowledge (L2)   — Patterns and rules
    ╱─────────╲
   ╱     I     ╲    Information (L1)  — Structured assessments
  ╱─────────────╲
 ╱       D       ╲  Data (L0)        — Raw observations
╱─────────────────╲
```

## How It Maps to Our Memory System

### Data (L0 — History)

**What:** Raw, unprocessed records of events. Chronological. Comprehensive. Noisy.

**In our system:** Daily markdown files (`memory/YYYY-MM-DD.md`). Everything gets logged — conversations, decisions, errors, deployments, discoveries. No filtering, no judgment. The goal is completeness.

**Characteristics:**
- High volume, low signal-to-noise
- Chronologically ordered
- Unstructured (free-form markdown)
- Retained for forensics and audit
- Cheapest to create, most expensive to search

**Example:**
```
## 10:42 — Task
Built the hierarchical memory skill. Started with SKILL.md, then schemas.
Had to iterate on the confidence formula three times. Settled on Bayesian smoothing.
Total time: ~45 minutes.
```

### Information (L1 — Evaluations)

**What:** Data that has been processed, structured, and given context. Answers "what happened and how well?"

**In our system:** JSON evaluation records (`memory/evaluations/YYYY-MM-DD.json`). Each significant task gets assessed: quality score, timing, successes, failures, tags. This is data with meaning.

**Characteristics:**
- Structured (JSON with defined schema)
- Assessment-oriented (quality, timing, outcomes)
- Tagged for cross-referencing
- Medium volume (1-5 per day typically)
- Created immediately after task completion

**Example:**
```json
{
  "task": "Built hierarchical memory skill",
  "quality": 4,
  "duration_minutes": 45,
  "expected_minutes": 60,
  "what_worked": ["Clear decomposition", "DIKW model as organizing principle"],
  "what_failed": ["Confidence formula needed 3 iterations"]
}
```

**The key transformation:** Raw log → Structured assessment with judgment.

### Knowledge (L2 — Lessons)

**What:** Patterns extracted from information. Rules, principles, and heuristics that apply across multiple situations. Answers "what generally works?"

**In our system:** Lesson records (`memory/lessons.json`). When the same observation appears 3+ times across evaluations, it becomes a lesson. Each lesson has evidence, confidence, and an actionable rule.

**Characteristics:**
- Pattern-based (requires multiple observations)
- Evidence-backed (links to specific evaluations)
- Confidence-scored (Bayesian smoothing)
- Actionable (every lesson has a "do this" rule)
- Low volume (tens of lessons, not hundreds)
- Updated incrementally as new evidence arrives

**Example:**
```json
{
  "pattern": "Complex skills need iteration on schemas/formulas",
  "evidence": ["eval-042", "eval-058", "eval-071"],
  "confidence": 0.63,
  "actionable_rule": "When building skills with data models, allocate 30% extra time for schema iteration"
}
```

**The key transformation:** Repeated observations → Generalized pattern with actionable rule.

### Wisdom (L3 — Insights)

**What:** Deep understanding that transcends specific domains. Principles that guide decision-making across contexts. Answers "what should we always do?"

**In our system:** `MEMORY.md` — the file loaded every session. Contains durable strategic truths, user preferences, and cross-domain principles that have proven reliable over time.

**Characteristics:**
- Cross-domain applicability
- High confidence (proven over many situations)
- Concise and actionable
- Rarely changes (durable truths)
- Smallest volume (fits in one readable file)
- Loaded into every session context

**Example:**
```
- Always build reference docs for complex skills — SKILL.md alone isn't enough
- Lucy prefers action over analysis — lead with the solution, explain after
- Schema design always takes longer than expected — budget 30% buffer
```

**The key transformation:** Proven patterns → Strategic principles that shape all future work.

## Why Four Levels?

### Compression Ratio

Each level compresses the one below by roughly 10:1:
- 100 daily log entries → 10 evaluations → 3 lessons → 1 insight
- This makes wisdom computationally cheap to access (small context window)

### Signal-to-Noise

Each promotion step filters noise:
- L0 captures everything (high noise)
- L1 extracts only what matters (structured)
- L2 finds only what repeats (proven)
- L3 keeps only what's durable (strategic)

### Retrieval Efficiency

Start at the top, drill down only when needed:
1. Check L3 first — usually sufficient for strategic decisions
2. Search L2 for domain-specific guidance
3. Drill to L1 for specific task context
4. L0 only for forensics/debugging

This is O(1) for common queries (L3 always loaded) and O(log n) for deep dives.

## Inspiration

This model draws from:
- **Russell Ackoff (1989):** Original DIKW hierarchy in "From Data to Wisdom"
- **Chat2Graph:** Graph-based DIKW implementation for conversational AI
- **Council Self-Improving skill:** Pattern tracking (3+ corrections → permanent rule)
- **Spaced repetition:** High-confidence items rise to always-available status
- **Knowledge management theory:** Nonaka & Takeuchi's knowledge creation spiral

## Anti-Patterns

1. **Hoarding at L0.** If daily files grow unbounded without promotion, the system is just a log, not a knowledge system.
2. **Premature promotion.** Moving a single observation to L2 without evidence creates unreliable lessons. Always require 3+ occurrences.
3. **L3 bloat.** If MEMORY.md becomes a dump of everything, it loses value. Prune aggressively.
4. **Skipping levels.** Don't go directly from L0 to L3. The intermediate levels exist for evidence accumulation and confidence building.
5. **Ignoring contradictions.** When new evidence contradicts a lesson, update or prune it. Stale knowledge is worse than no knowledge.
