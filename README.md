# ai-scripts

**Token-efficient AI coding workflow for terminal agents and Cursor.**

> Why use many token when few do trick.

---

## Problem

AI coding agents (Claude Code, OpenCode, Aider, ...) are powerful but wasteful:

- **Explore too much**: Run `ls`, `find`, `grep` randomly
- **Read too much**: Load entire files instead of just what matters
- **Output too much**: Write paragraphs when a sentence suffices
- **Cache nothing**: Re-analyze same files repeatedly

Each wasted token = slower response + higher cost + worse UX.

---

## Solution

This workflow constrains the AI to be **intentional** about every action:

1. **Human pre-processes context** with scripts → AI receives compressed data
2. **AI outputs structured JSON** → no prose narratives
3. **Files explicitly scoped** → no drift to unrelated files
4. **Outputs cached** → no re-analysis

Result: **~50-70% token reduction** while keeping full technical accuracy.

---

## Install

### Option 1: Local (per project) — recommended

Install into current directory:

```bash
curl -sSL https://raw.githubusercontent.com/phucle297/ai-scripts/main/install.sh | bash -s -- local
```

**Interactive menu:** After `scripts/` are installed, you get **1 / 2 / 3** (default **3**), similar to other CLIs—even with `curl | bash`, because the installer reads from **`/dev/tty`** when stdin is the download pipe.

From a clone you can run `./install.sh local` (same prompt).

| Choice | What gets created |
|--------|-------------------|
| **1 — Claude** | `CLAUDE.md` from the workflow template. If `CLAUDE.md` already exists → create `AGENTS.md` (if missing) and add a link from `CLAUDE.md` → `AGENTS.md`. Removes `.cursor/rules/ai-scripts.mdc` if present (Claude target does not use that rule). |
| **2 — Cursor** | `.cursor/rules/ai-scripts.mdc` (if missing). Does **not** create `CLAUDE.md`. If there is no `AGENTS.md` or `AI-GUIDE.md` yet → create `AGENTS.md`. |
| **3 — Other** | `AGENTS.md` if missing. If `AGENTS.md` already exists → create `AI-GUIDE.md` (if missing) and link from `AGENTS.md` → `AI-GUIDE.md`. |

**Always created:** `scripts/*` — 13 commands (symlinked or copied when installing from curl).

**Shell PATH:** Local install does **not** change your shell config. Run commands as `./scripts/ai-task`, … For `ai-task` on your PATH everywhere, use **Option 2 (global)** below.

Run `install.sh --help` for flags (`--claude`, `--cursor`, `--other`, `agents`).

Re-running local install **does not overwrite** an existing `.cursor/rules/ai-scripts.mdc`. To refresh that rule, copy `templates/cursor-ai-scripts.mdc` over `.cursor/rules/ai-scripts.mdc`.

Then auto-detect your project:

```bash
./scripts/init-project --agents
# Review output → paste into AGENTS.md
```

### Option 2: Global (personal tool)

Install once, use anywhere. This clones `~/.ai-scripts` and **appends** `~/.ai-scripts/bin` to your shell rc (`~/.zshrc`, `~/.bashrc`, …) so commands like `ai-task` work in any directory without `./scripts/`.

```bash
curl -sSL https://raw.githubusercontent.com/phucle297/ai-scripts/main/install.sh | bash -s -- global
```

Restart terminal (or `source ~/.zshrc`), then:

```bash
init-project --agents  # run from any project
```

### Cursor (after choosing **Cursor** at install)

Open the project folder in Cursor so `.cursor/rules/` applies. The bundled rule follows **AGENTS.md** / **AI-GUIDE.md**: **EXPLORE → PLAN → IMPLEMENT → COMMIT**. If you ask for implementation without an approved plan, the agent should **stop**, remind you, and offer either **you** driving the plan (e.g. paste `ai-task` output) or **explicit permission** for a read-only planning pass—then approval before any writes.

---

## Scripts

| Command             | When to use                              |
| ------------------ | ---------------------------------------- |
| `init-project`     | Auto-detect tech stack, commands, structure |
| `ai-task`          | Start new task — builds full context        |
| `ai-scripts init`  | Copy AGENTS.md to project                |
| `ctx-files`        | Find files by name                       |
| `ctx-symbol`       | Find where a function/type is defined       |
| `ctx-declarations` | Read .d.ts only (skip implementation)    |
| `ctx-imports`      | See what a file depends on               |
| `ctx-referencers`  | Find files that use a symbol              |
| `is-binary`       | Check if file is image/svg (skip reading)|
| `ctx-diff`         | Get clean diff (no lockfile noise)         |
| `ctx-errors`       | Extract only failures from test/lint     |

---

## Example Workflow

```bash
# 1. Build context for "Fix useUserProfile hook"
ai-task "userprofile" "useUserProfile" tsx > /tmp/ctx.txt
# Output: project tree + relevant files + symbol locations

# 2. Open agent, paste context
# Agent summarizes, flags ambiguities

# 3. Agent produces plan JSON
# You approve

# 4. After each step
ctx-diff

# 5. Commit
ctx-diff > /tmp/diff
# New session with diff → reviewer → verdict → commit
```

---

## AI Skill Rules

Add to your `AGENTS.md`:

```markdown
## AI SKILL RULES

- Never run ls/find/grep. Wait for file lists from scripts.
- Output JSON only. No prose.
- Only modify files in current step's scope.
- If file read in session, use cached. Don't re-read.
```

---

## Files

```
ai-scripts/
├── bin/                 # 13 commands
│   ├── ai-task         # All-in-one context builder
│   ├── init-project    # Auto-detect tech stack + structure
│   ├── ai-scripts     # init command
│   └── ...
├── templates/
│   ├── AGENTS.md              # Template to copy
│   └── cursor-ai-scripts.mdc # Cursor project rule template
├── install.sh         # Installer
└── README.md
```

---

## Compatible Agents

- Cursor (via `.cursor/rules/ai-scripts.mdc` on local install)
- OpenCode
- Claude Code
- Aider
- Codex CLI
- Roo Code / Kilo Code

---

## License

MIT
