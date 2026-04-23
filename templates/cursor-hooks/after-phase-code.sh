#!/usr/bin/env bash
# Cursor hook: runs on agent `stop` — use as “after Code / IMPLEMENT” in the ai-scripts workflow.
set -euo pipefail
cat >/dev/null

echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "  ai-scripts · after-phase-code (Cursor hook: stop)" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "" >&2
echo "  This fires when an agent run ends. In AGENTS.md terms, treat it as a" >&2
echo "  reminder after IMPLEMENT (Code): verify changes, run tests/lint, or" >&2
echo "  ./scripts/ctx-diff before you start the COMMIT / review step." >&2
echo "" >&2
echo "  Edit this file: .cursor/hooks/after-phase-code.sh" >&2
echo "  Wire-up: .cursor/hooks.json (copy from ai-scripts templates/cursor-hooks/)" >&2
echo "" >&2
exit 0
