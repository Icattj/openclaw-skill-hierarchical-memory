# Memory Schemas

JSON schemas for L1 (Evaluations) and L2 (Lessons) data structures.

## L1 — Evaluation Schema

**File:** `memory/evaluations/YYYY-MM-DD.json`
**Format:** JSON array of evaluation objects

```json
[
  {
    "id": "eval-NNN",
    "timestamp": "ISO 8601 — when the evaluation was created",
    "task": "string — brief description of what was done",
    "domain": "string — one of the standard domains (see below)",
    "agent": "string — which agent performed the task (michael, uriel, etc.)",
    "quality": "integer 1-5",
    "duration_minutes": "integer — actual time spent",
    "expected_minutes": "integer — estimated time (0 if no estimate)",
    "what_worked": ["string — positive observations"],
    "what_failed": ["string — negative observations or issues"],
    "tags": ["string — freeform tags for cross-referencing"],
    "l0_refs": ["string — references to L0 entries, e.g. memory/2026-04-04.md#section"]
  }
]
```

### Standard Domains
- `skill-building`
- `development`
- `outreach`
- `strategy`
- `operations`
- `design`
- `research`
- `memory`

### Quality Scale
| Score | Meaning |
|-------|---------|
| 1 | Failed — no useful output |
| 2 | Partial — significant issues remain |
| 3 | Completed — notable problems |
| 4 | Good — minor issues only |
| 5 | Excellent — no issues |

### Example
```json
[
  {
    "id": "eval-042",
    "timestamp": "2026-04-04T10:30:00Z",
    "task": "Built pipeline-orchestrator skill with 5-stage pipeline",
    "domain": "skill-building",
    "agent": "michael",
    "quality": 4,
    "duration_minutes": 45,
    "expected_minutes": 60,
    "what_worked": [
      "Clear task decomposition into stages",
      "Dual reasoning pattern worked well for structuring thought",
      "State schema was well-defined upfront"
    ],
    "what_failed": [
      "Sub-agent timed out — 5 min wasn't enough for complex skill writing",
      "References files not all completed in first pass"
    ],
    "tags": ["skill", "pipeline", "architecture", "sub-agent"],
    "l0_refs": ["memory/2026-04-04.md#pipeline-build"]
  }
]
```

---

## L2 — Lesson Schema

**File:** `memory/lessons.json`
**Format:** JSON array of lesson objects

```json
[
  {
    "id": "lesson-NNN",
    "pattern": "string — descriptive summary of the repeated observation",
    "evidence": ["string — evaluation IDs that support this pattern"],
    "first_seen": "YYYY-MM-DD — date pattern was first observed",
    "last_seen": "YYYY-MM-DD — date of most recent evidence",
    "occurrences": "integer — number of times pattern appeared",
    "confidence": "float 0.0-0.95 — calculated via formula",
    "domain": "string — primary domain",
    "actionable_rule": "string — concrete 'do this' instruction",
    "status": "active | pruned | promoted"
  }
]
```

### Status Values
| Status | Meaning |
|--------|---------|
| `active` | Lesson is current and used in queries |
| `pruned` | Confidence too low or contradicted — excluded from active queries |
| `promoted` | Distilled into L3 (MEMORY.md) — still active for reference |

### Confidence Formula
```
confidence = min(0.95, occurrences / (occurrences + 3))
```

### Example
```json
[
  {
    "id": "lesson-005",
    "pattern": "Complex skills need reference documentation beyond SKILL.md",
    "evidence": ["eval-012", "eval-028", "eval-042", "eval-055", "eval-061"],
    "first_seen": "2026-03-15",
    "last_seen": "2026-04-04",
    "occurrences": 5,
    "confidence": 0.625,
    "domain": "skill-building",
    "actionable_rule": "Always create references/ folder with deep-dive docs when a skill covers 3+ concepts or has complex state management",
    "status": "active"
  },
  {
    "id": "lesson-008",
    "pattern": "Sub-agent timeouts on complex generation tasks",
    "evidence": ["eval-042", "eval-048", "eval-053"],
    "first_seen": "2026-04-04",
    "last_seen": "2026-04-06",
    "occurrences": 3,
    "confidence": 0.5,
    "domain": "development",
    "actionable_rule": "Set sub-agent timeout to 10+ minutes for skill/doc generation tasks. 5 minutes is not enough.",
    "status": "active"
  }
]
```

---

## Evaluation Counter

**File:** `memory/evaluations/.counter`
**Format:** Plain text, single integer

```
42
```

This tracks the next evaluation ID to assign. Increment after each use.
If the file doesn't exist, scan existing evaluation files for the highest `eval-NNN` and start from there + 1.

---

## Archive Summary Schema

**File:** `memory/evaluations/archive/YYYY-MM-summary.json`
**Format:** JSON object summarizing a month of evaluations

```json
{
  "month": "YYYY-MM",
  "totalEvaluations": 23,
  "averageQuality": 3.7,
  "domains": {
    "skill-building": 8,
    "development": 6,
    "operations": 5,
    "outreach": 4
  },
  "topTags": ["pipeline", "testing", "deployment", "ocr"],
  "commonSuccesses": [
    "Clear decomposition of complex tasks",
    "Good use of parallel execution"
  ],
  "commonFailures": [
    "Timeout issues with sub-agents",
    "Schema iteration needed"
  ],
  "timingAccuracy": {
    "avgOverrun": 15,
    "percentOnTime": 0.65
  }
}
```
