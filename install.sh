#!/bin/bash
# ai-scripts installer
# Usage: curl -sSL https://raw.githubusercontent.com/phucle297/ai-scripts/main/install.sh | bash -s -- local [claude|cursor|other]
# Or:   ./install.sh [global|local] [claude|cursor|other|agents]
#       ./install.sh local --cursor
# Env:  AI_SCRIPTS_AGENT=claude|cursor|other  (non-interactive local install)

set -e

INSTALL_DIR="${AI_SCRIPTS_DIR:-$HOME/.ai-scripts}"
REPO_URL="${REPO_URL:-https://github.com/phucle297/ai-scripts.git}"
MODE=""
# claude | cursor | other — local install only (docs / Cursor rules)
AGENT_TARGET="${AI_SCRIPTS_AGENT:-}"

# Parse arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
	-h | --help)
		echo "Usage: install.sh [global|local] [claude|cursor|other|agents]"
		echo ""
		echo "  global   Install to ~/.ai-scripts ($HOME/.ai-scripts)"
		echo "  local    Install to current directory"
		echo ""
		echo "  claude | --claude   CLAUDE.md (or AGENTS.md + link if CLAUDE.md exists)"
		echo "  cursor | --cursor   .cursor/rules/ai-scripts.mdc (+ AGENTS.md if no workflow file)"
		echo "  other  | --other    AGENTS.md (or AI-GUIDE.md + link if AGENTS.md exists)"
		echo "  agents              same as other"
		echo ""
		echo "  AI_SCRIPTS_AGENT    non-interactive agent choice (local install)"
		echo ""
		echo "Default mode: local if inside a git repo, else global."
		echo "Local install: interactive menu (stdin or /dev/tty). If neither is available (CI), defaults to other unless you set AI_SCRIPTS_AGENT or pass claude|cursor|other."
		exit 0
		;;
	global | --global | -g)
		MODE="global"
		shift
		;;
	local | --local | -l)
		MODE="local"
		shift
		;;
	--claude)
		AGENT_TARGET="claude"
		shift
		;;
	--cursor)
		AGENT_TARGET="cursor"
		shift
		;;
	--other | --agents)
		AGENT_TARGET="other"
		shift
		;;
	claude | cursor | other)
		AGENT_TARGET="$1"
		shift
		;;
	agents)
		AGENT_TARGET="other"
		shift
		;;
	-*)
		shift
		;;
	*)
		shift
		;;
	esac
done

# Get script directory — handle piped case where BASH_SOURCE[0] is empty
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're running from a cloned repo or just the install script
if [[ ! -d "$SCRIPT_DIR/bin" ]]; then
	TEMP_DIR=$(mktemp -d)
	git clone --depth 1 "$REPO_URL" "$TEMP_DIR"
	SCRIPT_DIR="$TEMP_DIR"
fi

INSTALL_DIR="${AI_SCRIPTS_DIR:-$HOME/.ai-scripts}"

echo "ai-scripts installer"

# Add to shell rc
add_to_shell_rc() {
	for RC_FILE in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile" "$HOME/.config/fish/config.fish"; do
		if [[ -f "$RC_FILE" ]] || [[ "$RC_FILE" == "$HOME/.bashrc" ]] || [[ "$RC_FILE" == "$HOME/.zshrc" ]]; then
			touch "$RC_FILE" 2>/dev/null || continue
			if grep -q "\.ai-scripts/bin" "$RC_FILE" 2>/dev/null; then
				continue
			fi
			if [[ "$RC_FILE" == "$HOME/.config/fish/config.fish" ]]; then
				echo "" >>"$RC_FILE"
				echo "# ai-scripts" >>"$RC_FILE"
				echo "set -gx PATH $INSTALL_DIR/bin \$PATH" >>"$RC_FILE"
			else
				echo "" >>"$RC_FILE"
				echo "# ai-scripts" >>"$RC_FILE"
				echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >>"$RC_FILE"
			fi
			echo "✅ Added to $RC_FILE"
		fi
	done
}

# Install global
install_global() {
	echo "Installing global to $INSTALL_DIR..."

	if [[ -d "$INSTALL_DIR/.git" ]]; then
		echo "Updating..."
		cd "$INSTALL_DIR" && git pull
	else
		rm -rf "$INSTALL_DIR"
		git clone "$REPO_URL" "$INSTALL_DIR"
	fi

	chmod +x "$INSTALL_DIR"/bin/*

	add_to_shell_rc

	echo ""
	echo "Run this to apply now:"
	echo "  source ~/.zshrc"
	echo "  source ~/.bashrc"
	echo "  source ~/.config/fish/config.fish"
}

choose_agent_target() {
	if [[ -n "$AGENT_TARGET" ]]; then
		case "$AGENT_TARGET" in
		claude | cursor | other) return 0 ;;
		*)
			echo "⚠️  Invalid AI_SCRIPTS_AGENT/choice: $AGENT_TARGET (use claude, cursor, other)"
			AGENT_TARGET=""
			;;
		esac
	fi

	# Piped installs (curl | bash) leave stdin non-interactive; read from controlling TTY when available.
	echo "" >&2
	echo "Which AI tool is primary for this project?" >&2
	echo "  1) Claude Code — CLAUDE.md (if it already exists → AGENTS.md + link from CLAUDE.md)" >&2
	echo "  2) Cursor — .cursor/rules/ai-scripts.mdc (+ AGENTS.md if no workflow file yet)" >&2
	echo "  3) Other (OpenCode, Codex CLI, …) — AGENTS.md (if it exists → AI-GUIDE.md + link from AGENTS.md)" >&2

	_choice=""
	if [[ -t 0 ]]; then
		read -r -p "Enter 1–3 [3]: " _choice
	elif [[ -r /dev/tty ]] && [[ -c /dev/tty ]]; then
		read -r -p "Enter 1–3 [3]: " _choice </dev/tty
	else
		AGENT_TARGET="other"
		echo "No interactive terminal (stdin is not a TTY and /dev/tty unavailable). Defaulting to \"other\" (AGENTS.md)." >&2
		echo "  For CI: set AI_SCRIPTS_AGENT=claude|cursor|other or pass: install.sh local <target>" >&2
		return
	fi

	_choice=${_choice:-3}
	case "$_choice" in
	1) AGENT_TARGET="claude" ;;
	2) AGENT_TARGET="cursor" ;;
	*) AGENT_TARGET="other" ;;
	esac
	echo "→ Using: $AGENT_TARGET" >&2
}

append_link_once() {
	local target="$1"
	local line="$2"
	if [[ ! -f "$target" ]]; then
		return 0
	fi
	if grep -qF "${line}" "$target" 2>/dev/null; then
		return 0
	fi
	echo "" >>"$target"
	echo "$line" >>"$target"
}

install_docs_claude() {
	local tpl="$SCRIPT_DIR/templates/AGENTS.md"
	[[ -f "$tpl" ]] || return 0

	if [[ ! -f "CLAUDE.md" ]]; then
		cp "$tpl" CLAUDE.md
		echo "✅ Created CLAUDE.md"
		return 0
	fi

	echo "ℹ️  CLAUDE.md already exists"
	if [[ ! -f "AGENTS.md" ]]; then
		cp "$tpl" AGENTS.md
		echo "✅ Created AGENTS.md"
	else
		echo "ℹ️  AGENTS.md already exists (skipped copy)"
	fi
	if ! grep -q "AGENTS.md" CLAUDE.md 2>/dev/null; then
		append_link_once CLAUDE.md "See [AGENTS.md](./AGENTS.md) for AI agent context."
		echo "✅ Updated CLAUDE.md → links to AGENTS.md"
	fi

	# Claude target: do not keep Cursor project rule from this installer
	if [[ -f ".cursor/rules/ai-scripts.mdc" ]]; then
		rm -f ".cursor/rules/ai-scripts.mdc"
		echo "✅ Removed .cursor/rules/ai-scripts.mdc (Claude target — not used)"
	fi
}

install_docs_cursor() {
	if [[ -f "$SCRIPT_DIR/templates/cursor-ai-scripts.mdc" ]]; then
		mkdir -p .cursor/rules
		if [[ ! -f ".cursor/rules/ai-scripts.mdc" ]]; then
			cp "$SCRIPT_DIR/templates/cursor-ai-scripts.mdc" ".cursor/rules/ai-scripts.mdc"
			echo "✅ Copied .cursor/rules/ai-scripts.mdc"
		else
			echo "ℹ️  .cursor/rules/ai-scripts.mdc already exists (skipped)"
		fi
	fi

	# Cursor target: never create CLAUDE.md; optional workflow file is AGENTS.md / AI-GUIDE only
	if [[ -f "CLAUDE.md" ]]; then
		echo "ℹ️  CLAUDE.md is present (not created by Cursor target). Cursor uses .cursor/rules — remove CLAUDE.md if you do not use Claude Code here." >&2
	fi

	local tpl="$SCRIPT_DIR/templates/AGENTS.md"
	[[ -f "$tpl" ]] || return 0
	if [[ ! -f "AGENTS.md" ]] && [[ ! -f "AI-GUIDE.md" ]]; then
		cp "$tpl" AGENTS.md
		echo "✅ Created AGENTS.md (workflow doc; no AGENTS.md or AI-GUIDE.md yet)"
	fi
}

install_docs_other() {
	local tpl="$SCRIPT_DIR/templates/AGENTS.md"
	[[ -f "$tpl" ]] || return 0

	if [[ ! -f "AGENTS.md" ]]; then
		cp "$tpl" AGENTS.md
		echo "✅ Created AGENTS.md"
		return 0
	fi

	echo "ℹ️  AGENTS.md already exists"
	if [[ ! -f "AI-GUIDE.md" ]]; then
		cp "$tpl" AI-GUIDE.md
		echo "✅ Created AI-GUIDE.md"
	else
		echo "ℹ️  AI-GUIDE.md already exists (skipped copy)"
	fi
	if ! grep -q "AI-GUIDE.md" AGENTS.md 2>/dev/null; then
		append_link_once AGENTS.md "See [AI-GUIDE.md](./AI-GUIDE.md) for full AI agent workflow."
		echo "✅ Updated AGENTS.md → links to AI-GUIDE.md"
	fi
}

# Install local (current directory)
install_local() {
	echo "Installing to current directory..."

	mkdir -p scripts
	chmod +x "$SCRIPT_DIR"/bin/*

	for script in "$SCRIPT_DIR"/bin/*; do
		name=$(basename "$script")
		if [[ -f "scripts/$name" ]] || [[ -L "scripts/$name" ]]; then
			rm -f "scripts/$name"
		fi
		if [[ -n "$TEMP_DIR" ]]; then
			cp "$script" "scripts/$name"
			chmod +x "scripts/$name"
			echo "✅ Copied scripts/$name"
		else
			ln -sf "$script" "scripts/$name"
			echo "✅ Linked scripts/$name"
		fi
	done

	choose_agent_target

	case "$AGENT_TARGET" in
	claude)
		install_docs_claude
		;;
	cursor)
		install_docs_cursor
		;;
	other)
		install_docs_other
		;;
	esac

	echo ""
	echo "Done! Your project now has:"
	echo "  - scripts/*"
	[[ -f "CLAUDE.md" ]] && echo "  - CLAUDE.md"
	[[ -f "AGENTS.md" ]] && echo "  - AGENTS.md"
	[[ -f "AI-GUIDE.md" ]] && echo "  - AI-GUIDE.md"
	[[ -f ".cursor/rules/ai-scripts.mdc" ]] && echo "  - .cursor/rules/ai-scripts.mdc"

	if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
		rm -rf "$TEMP_DIR"
	fi
}

# Auto-detect mode
if [[ -z "$MODE" ]]; then
	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		MODE="local"
	else
		MODE="global"
	fi
fi

# Main
case "$MODE" in
global)
	install_global
	;;
local)
	install_local
	;;
esac
