#!/usr/bin/env bash
# Cursor hook: runs after shell commands matching `git commit` — “after Commit” in ai-scripts workflow.
set -euo pipefail
cat >/dev/null

echo "" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "  ai-scripts · after-phase-commit (Cursor hook: afterShellExecution)" >&2
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >&2
echo "" >&2
echo "  This fires after a terminal command that matches: git commit" >&2
echo "  (see matcher in .cursor/hooks.json). Use it for post-commit automation:" >&2
echo "  push, tags, release notes, CI triggers, etc." >&2
echo "" >&2
echo "  Edit this file: .cursor/hooks/after-phase-commit.sh" >&2
echo "  Wire-up: .cursor/hooks.json (copy from ai-scripts templates/cursor-hooks/)" >&2
echo "" >&2
exit 0
