# Cursor hooks (ai-scripts) — separate from rules

These files are **not** installed by `install.sh`. Set them up **manually** when you want hooks.

They map loosely to **AGENTS.md** phases:

| Phase in workflow | Cursor event | Script |
|-------------------|--------------|--------|
| After **IMPLEMENT** (Code) | `stop` (agent run finished) | `after-phase-code.sh` |
| After **COMMIT** | `afterShellExecution` when command matches `git commit` | `after-phase-commit.sh` |

Default scripts only **print** what to do next; replace their bodies with real commands.

## Setup

From your project root (paths assume you vendor or clone **ai-scripts**):

```bash
mkdir -p .cursor/hooks
cp /path/to/ai-scripts/templates/cursor-hooks/hooks.json .cursor/hooks.json
cp /path/to/ai-scripts/templates/cursor-hooks/after-phase-*.sh .cursor/hooks/
chmod +x .cursor/hooks/after-phase-code.sh .cursor/hooks/after-phase-commit.sh
```

If you already have `.cursor/hooks.json`, **merge** the `stop` and `afterShellExecution` entries instead of overwriting.

## Notes

- **`stop`** runs when an agent session ends — not a perfect “phase” boundary, but matches “done coding for this run.”
- **`git commit` matcher** uses Cursor’s hook matcher rules (substring on the full command). Adjust in `hooks.json` if you use aliases or `git -C … commit`.
- **Claude Code** does not use this file; use Claude’s own hooks/settings if needed.

See [Cursor hooks documentation](https://cursor.com/docs).
