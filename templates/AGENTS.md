# AI-Assisted Coding Workflow

**Model-agnostic · Terminal-native · Token-efficient · Subagent-ready**

---

## Overview

**Instruct AI, not human.** Constrain AI reads/writes/outputs — every token intentional. Humans pre-process context → feed compressed inputs. AI receives structured data → returns structured output → never explores alone.

```
INPUT → 1.EXPLORE → 2.PLAN → 3.IMPLEMENT → 4.COMMIT → LOOP
```

---

## Project Setup

### 1. AGENTS.md

Auto-read at session start. 2 purposes: project context + behavioral constraints.

| Tool | File |
|------|------|
| Cursor | `.cursor/rules/*.mdc` (from `templates/cursor/*.mdc` on local install; follows this doc) |
| OpenCode, Codex CLI | AGENTS.md |
| Claude Code | CLAUDE.md |
| Aider | .aider.conf.yml |

### 2. Pre-commit hook

```bash
#!/bin/sh
npm run lint || exit 1
npm test -- --run || exit 1
```

### 3. Helper scripts

```bash
mkdir -p scripts && chmod +x scripts/*.sh
```

---

## Which script for what

| Scenario | Script |
|----------|--------|
| Find files by keyword | `ctx-files <keyword> [ext]` |
| Find symbol def + usages | `ctx-symbol <SymbolName>` |
| Read .d.ts only | `ctx-declarations <file.ts>` |
| List dependencies IN file | `ctx-imports <file.ext>` |
| Find files USE symbol | `ctx-referencers <SymbolName>` |
| Check path exists | `ctx-check-path <path>` |
| Check if binary | `is-binary <file>` |
| Get test/lint errors | `npm test 2>&1 | ctx-errors` |
| Clean diff | `ctx-diff [base]` |
| Project tree | `ctx-tree [depth]` |
| All-in-one context | `ai-task <keyword> <symbol> [ext]` |

---

## Patterns

```bash
# Build full context
ai-task "feature" "useHook" tsx > /tmp/ctx.txt

# Read .ts file: declaration first
ctx-declarations component.ts

# Check if binary before reading
is-binary logo.svg  # "binary" → skip

# Find who uses this hook
ctx-referencers useUserProfile
```

---

## AI SKILL RULES

### Input handling
- Never run `ls`, `find`, `glob`, `grep` independently. Wait for file lists.
- Never read file not provided in prompt.
- If file read session, use cached. Don't re-read.
- Missing context → `{ "status": "blocked", "needs": ["path"] }`

### Output compression
- Structured outputs: JSON, not prose.
- Do not explain. Do it.
- Don't add narratives. Return JSON status.
- One-sentence max between steps.

### Caching rules
- Same file content consecutive → cached. Don't re-analyze.
- Same command output appears → reference, don't re-analyze.

### Scope enforcement
- Only modify files in current step's `files` field.
- Change outside scope → `{ "status": "blocked", "out_of_scope": ["path"] }`

### Model behavior
- EXPLORE/PLAN: read-only. No file writes.
- IMPLEMENT: write only to files in scope.
- REVIEW: diff only. No file access.

---

## Model & Mode Control

### When switch model

| Phase | Model | Reason |
|-------|-------|--------|
| EXPLORE | Fast/cheap | Read-only, no reasoning |
| PLAN | Strong | Architecture decisions matter |
| IMPLEMENT - boilerplate | Fast/cheap | Mechanical execution |
| IMPLEMENT - complex logic | Strong | Reasoning quality |
| REVIEW | Strong | Must catch subtle bugs |

### Plan vs Build mode
- **plan**: read files, no writes. EXPLORE/PLAN.
- **build**: read + write. IMPLEMENT.

---

## Subagent Architecture

```
ORCHESTRATOR → assigns work → tracks state
  ├─ WORKER A    steps 2,3 (parallel)
  ├─ WORKER B    steps 4,5 (parallel)
  └─ REVIEWER    diff only → review JSON
```

### Roles
- **Orchestrator**: reads context, produces plan JSON, delegates.
- **Worker**: one task, scoped files, returns status JSON.
- **Reviewer**: diff only, no context, returns review JSON.

### Prompt templates

#### Orchestrator (EXPLORE + PLAN)
```
You are orchestrator. PLAN mode: read files, no code.

Input: [task]
Context: [script outputs]

Read listed files. Produce plan JSON:
[
  { "step": 1, "description": "...", "files": ["path"], "depends_on": [], "parallel": false }
]
Identify workers. Wait for approval.
```

#### Worker
```
You are worker. Implement one task.

Task: [step description]
Files: [list]

Only modify listed files. Return: { "step": N, "files_modified": [], "status": "done" | "blocked" }
```

#### Reviewer
```
You are reviewer. No implementation context.

Diff: [ctx-diff output]

Criteria: correctness, scope, risk, style.
Return: { "verdict": "approve" | "request_changes" | "block", "issues": [], "summary": "..." }
```

---

## Four Phases

### Phase 1 — EXPLORE
Run scripts → build context → open agent in PLAN mode → summarize → flag ambiguities.

### Phase 2 — PLAN
Still PLAN mode → ask for plan JSON → approve/modify/reject → save `.plan.json`.

### Phase 3 — IMPLEMENT
BUILD mode + bypass → execute steps → verify with `ctx-diff`.

### Phase 4 — COMMIT
New session with diff → reviewer → verdict → commit with quality gate.

---

## Token Reduction

| Technique | Savings |
|-----------|---------|
| AI skill rules | **Very high** |
| Helper scripts | **Very high** |
| JSON output | **High** |
| Subagents | **High** |
| Plan then build | **High** |
| Caching | **High** |
| .d.ts first | **Medium** |
| Check binary | **Medium** |
| ctx-errors | **Medium** |
| Cheap model EXPLORE | **Medium** |

---

## Quick Reference

```
SETUP once
  └─ AGENTS.md
  └─ pre-commit hook
  └─ ai-scripts (global or project)

NEW TASK
  └─ ai-task "keyword" "symbol" > /tmp/ctx.txt
  └─ open agent PLAN mode
  └─ EXPLORE → PLAN → approve
  └─ echo '[plan]' > .plan.json

IMPLEMENT
  └─ switch BUILD mode
  └─ enable --dangerously-skip-permissions
  └─ execute steps → verify diff

COMMIT
  └─ ctx-diff > /tmp/diff
  └─ NEW session → reviewer → verdict
  └─ git add -p → commit
  └─ hook runs: lint → test → ✓/✗
```

---

## Troubleshooting

- AI runs ls/find → add: "No ls/find/grep. File list provided above."
- Worker outside scope → "Return blocked if need unlisted file."
- Reviewer biased → NEW session, diff only, no history.
- Parallel conflict → ensure no file overlap.
- Bypass unwanted change → `git checkout -- <file>`.