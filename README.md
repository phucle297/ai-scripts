# ai-scripts

**Frontend-first, token-efficient AI workflow** for **Cursor**, terminal agents, and **React / Next / Vue / Svelte**-style codebases.

> Why use many token when few do trick.

**This version is optimized for UI work:** component boundaries, a11y, styling, and TypeScript-heavy frontends. Shell helpers (`ctx-*`, `ai-task`) work in any repo, but **Cursor rules and examples assume you ship a modern frontend**.

### Why this exists

I’m a frontend developer on a tight budget — I built **ai-scripts** first **for my own** day-to-day use (fewer tokens, cheaper runs, faster UI iteration). Sharing it is a bonus. Today the defaults are **intentionally frontend-heavy**; **a more general, stack-agnostic edition** is something I plan to add down the road. Until then, think of this repo as a **UI-first** toolkit, not a neutral fit for every backend stack.

---

## Problem

AI agents burn tokens fastest on **frontend** work:

- **Explore too much**: `ls` / `find` / `grep` instead of scoped file lists
- **Read too much**: whole components and design files when only a hook or leaf matters
- **Output too much**: prose instead of plans, diffs, or JSON
- **Inconsistent UI**: one-off styles, weak a11y, Server vs Client confusion in Next
- **Cache nothing**: re-read the same `tsx` / `css` trees every message

Each wasted token = slower iteration, higher cost, and weaker UI quality.

---

## Solution

1. **Compress context** with scripts → paste into the agent (tree + relevant paths + symbols)
2. **Structured phases** (EXPLORE → PLAN → IMPLEMENT → COMMIT) → less drift and safer edits
3. **Cursor rules** tuned for **frontend + TS/JS + CSS** (`frontend.mdc`, `coding-style.mdc`, plus workflow + hygiene)
4. **Optional hooks** after “code” and after `git commit` → see `templates/cursor-hooks/`

Typical outcome: **large token savings** on real UI tasks while keeping reviews and scope tight.

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
| **1 — Claude** | `CLAUDE.md` from the workflow template. If `CLAUDE.md` already exists → create `AGENTS.md` (if missing) and add a link from `CLAUDE.md` → `AGENTS.md`. Removes `.cursor/rules/*.mdc` that correspond to `templates/cursor/*.mdc` (Claude target does not use Cursor rules). |
| **2 — Cursor** | **Recommended for frontend teams.** Copies **`templates/cursor/*.mdc`** → `.cursor/rules/` (`ai-scripts` workflow, **`frontend`**, **`coding-style`**, `code-hygiene` — skipped if a file already exists). Does **not** create `CLAUDE.md`. If there is no `AGENTS.md` or `AI-GUIDE.md` yet → create `AGENTS.md`. |
| **3 — Other** | `AGENTS.md` if missing. If `AGENTS.md` already exists → create `AI-GUIDE.md` (if missing) and link from `AGENTS.md` → `AI-GUIDE.md`. |

**Always created:** `scripts/*` — 13 commands (symlinked or copied when installing from curl).

**Shell PATH:** Local install does **not** change your shell config. Run commands as `./scripts/ai-task`, … For `ai-task` on your PATH everywhere, use **Option 2 (global)** below.

Run `install.sh --help` for flags (`--claude`, `--cursor`, `--other`, `agents`).

Re-running local install **does not overwrite** existing `.cursor/rules/*.mdc` files. To refresh, copy from **`templates/cursor/`** in this repo (see `templates/cursor/README.md`).

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

Open the project folder in Cursor. The bundle is **frontend-centric** (from **`templates/cursor/`**):

- **`frontend.mdc`** — primary UI rule: React/Next (RSC vs client), a11y, styling, i18n, performance habits (`globs`: TSX/JSX/Vue/Svelte/Astro/CSS).
- **`coding-style.mdc`** — match Prettier/Biome/ESLint, imports, naming, small diffs (covers TS/JS/CSS and common config).
- **`code-hygiene.mdc`** — secrets, boundaries, errors (still useful next to UI code).
- **`ai-scripts.mdc`** — workflow with **AGENTS.md** / **AI-GUIDE.md**: phases, plan-before-implement, `ctx-*` discipline (`alwaysApply: true`).

Rules with **`globs`** apply when those file types are in context; remove or edit `.mdc` files if your stack is different.

**Hooks (optional, separate):** **`templates/cursor-hooks/`** — copy into `.cursor/` yourself; default scripts echo guidance for **after Code** (`stop`) and **after Commit** (`afterShellExecution` + `git commit`). See **`templates/cursor-hooks/README.md`**.

---

## Scripts

Great for **feature work in `tsx`/`jsx`/`vue`**: find components, trace hooks, and ship smaller prompts.

| Command             | When to use                              |
| ------------------ | ---------------------------------------- |
| `init-project`     | Auto-detect stack (Node/Next/Vite show up often in frontend repos) |
| `ai-task`          | One-shot context: tree + files + optional symbol — e.g. hook + keyword |
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

## Example workflow (frontend)

```bash
# 1. Build context for a UI task (e.g. fix useUserProfile)
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
│   ├── AGENTS.md           # Template to copy
│   ├── cursor/             # Cursor rules only (see cursor/README.md)
│   │   └── *.mdc
│   └── cursor-hooks/     # Optional Cursor hooks (manual setup; see cursor-hooks/README.md)
├── install.sh         # Installer
└── README.md
```

---

## Compatible agents

- **Cursor** — best match: install **Cursor** target for the frontend rule pack
- OpenCode, Claude Code, Aider, Codex CLI, Roo / Kilo — use **`AGENTS.md`** / **`CLAUDE.md`** + scripts; no bundled `.mdc` rules

---

## License

MIT
