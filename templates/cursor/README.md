# Cursor templates (ai-scripts)

**Frontend-first rule pack** for Cursor: TSX/JSX, styling, a11y, and Next/React patterns are the main focus. Copied when you run **`install.sh local`** and choose **Cursor** (see repo root `README.md`).

| File | Installed as | Role |
|------|----------------|------|
| `frontend.mdc` | `.cursor/rules/frontend.mdc` | **Primary UI rule** — a11y, React/Next, styling (`globs`) |
| `coding-style.mdc` | `.cursor/rules/coding-style.mdc` | Formatters, imports, naming — tuned for TS/JS/CSS repos (`globs`) |
| `code-hygiene.mdc` | `.cursor/rules/code-hygiene.mdc` | Security, errors, boundaries (`globs`) |
| `ai-scripts.mdc` | `.cursor/rules/ai-scripts.mdc` | Workflow + plan gate (`alwaysApply: true`) |

Existing `.cursor/rules/*.mdc` files are **not overwritten**; delete or merge manually, then re-copy from here if needed.

**Hooks** are maintained separately: see **`templates/cursor-hooks/`** (not installed by `install.sh`).
