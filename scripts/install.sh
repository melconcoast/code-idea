#!/usr/bin/env bash
#
# Install code-idea's four skills into whichever coding agent(s) you use.
#
# Every supported agent except Claude Code reads the shared `.agents/skills/`
# convention, so most targets resolve to the same directory and are copied once.
# Claude Code is the exception: it reads `.claude/skills/`, `~/.claude/skills/`,
# or a plugin, never `.agents/skills/`.
#
#   ./scripts/install.sh                  # detect agents, install into this project
#   ./scripts/install.sh --global         # install for all your projects
#   ./scripts/install.sh --agent codex --agent cursor
#   ./scripts/install.sh --all --dry-run
#
# Claude Code users are usually better served by the plugin, which keeps the
# skills updatable via /plugin:
#   /plugin marketplace add melconcoast/code-idea
#   /plugin install code-idea@melconcoast

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/.agents/skills"

GLOBAL=0
DRY_RUN=0
ALL=0
TARGET_DIR="$PWD"
SELECTED=()

# Agent registry: name|project path|global path|detection probe
#
# Paths come from each agent's own documentation. Where an agent reads several
# locations, the shared `.agents/` convention is preferred so one copy serves
# every agent that honours it.
#
#   claude-code     code.claude.com/docs/en/skills
#   codex           learn.chatgpt.com/docs/build-skills
#   cursor          cursor.com/docs/skills
#   gemini-cli      github.com/google-gemini/gemini-cli/blob/main/docs/cli/skills.md
#   github-copilot  docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills
#   kimi-code       moonshotai.github.io/kimi-cli/en/customization/skills.html
#   deepseek        github.com/deepseek-ai/deepseek-harness (ships its own .agents/skills/)
#
# Verified 2026-08-23. Agent context loading changes fast; treat a stale row as
# a welcome PR rather than a bug, the same way references/agent-profiles.md does.
AGENTS=(
  "claude-code|.claude/skills|$HOME/.claude/skills|$HOME/.claude"
  "codex|.agents/skills|$HOME/.agents/skills|$HOME/.codex"
  "cursor|.agents/skills|$HOME/.cursor/skills|$HOME/.cursor"
  "gemini-cli|.agents/skills|$HOME/.gemini/skills|$HOME/.gemini"
  "github-copilot|.agents/skills|$HOME/.copilot/skills|$HOME/.copilot"
  "kimi-code|.agents/skills|$HOME/.agents/skills|$HOME/.kimi"
  "deepseek|.agents/skills|$HOME/.agents/skills|$HOME/.dsh"
)

usage() {
  cat <<EOF
Install code-idea's skills (scaffold, plan-module, execute-plan, test-and-verify).

Usage: ./scripts/install.sh [options]

  --global, -g          Install for all projects, not just this one
  --agent NAME, -a      Install for a specific agent (repeatable)
  --all                 Install for every supported agent
  --dir PATH            Project to install into (default: current directory)
  --list                List supported agents and their paths, then exit
  --dry-run             Show what would be copied, change nothing
  --help, -h            This message

Supported agents: $(printf '%s ' "${AGENTS[@]%%|*}")

With no --agent or --all, the script detects which agents are configured on this
machine and asks before installing.
EOF
}

list_agents() {
  printf '%-16s %-24s %s\n' "AGENT" "PROJECT" "GLOBAL"
  for row in "${AGENTS[@]}"; do
    IFS='|' read -r name proj glob _ <<<"$row"
    printf '%-16s %-24s %s\n' "$name" "$proj" "${glob/#$HOME/~}"
  done
}

while [ $# -gt 0 ]; do
  case "$1" in
    -g|--global) GLOBAL=1; shift ;;
    -a|--agent)  SELECTED+=("$2"); shift 2 ;;
    --all)       ALL=1; shift ;;
    --dir)       TARGET_DIR="$2"; shift 2 ;;
    --list)      list_agents; exit 0 ;;
    --dry-run)   DRY_RUN=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

[ -d "$SKILLS_SRC" ] || { echo "error: no skills found at $SKILLS_SRC" >&2; exit 1; }

SKILL_NAMES=()
for d in "$SKILLS_SRC"/*/; do
  [ -f "$d/SKILL.md" ] && SKILL_NAMES+=("$(basename "$d")")
done
[ ${#SKILL_NAMES[@]} -gt 0 ] || { echo "error: no SKILL.md found under $SKILLS_SRC" >&2; exit 1; }

# Resolve which agents to install for.
if [ "$ALL" = "1" ]; then
  for row in "${AGENTS[@]}"; do SELECTED+=("${row%%|*}"); done
elif [ ${#SELECTED[@]} -eq 0 ]; then
  detected=()
  for row in "${AGENTS[@]}"; do
    IFS='|' read -r name _ _ probe <<<"$row"
    if [ -e "$probe" ] || command -v "$name" >/dev/null 2>&1; then
      detected+=("$name")
    fi
  done
  if [ ${#detected[@]} -eq 0 ]; then
    echo "No coding agents detected on this machine."
    echo "Pick one explicitly with --agent NAME, or --list to see the options."
    exit 1
  fi
  echo "Detected: ${detected[*]}"
  if [ -t 0 ]; then
    printf 'Install code-idea skills for these? [Y/n] '
    read -r reply
    case "$reply" in [nN]*) echo "Nothing installed."; exit 0 ;; esac
  fi
  SELECTED=("${detected[@]}")
fi

# Resolve destinations, collapsing agents that share one directory so the shared
# `.agents/skills/` path is written once rather than N times.
declare -a DESTS=()
declare -a DEST_LABELS=()
for want in "${SELECTED[@]}"; do
  found=""
  for row in "${AGENTS[@]}"; do
    IFS='|' read -r name proj glob _ <<<"$row"
    if [ "$name" = "$want" ]; then
      if [ "$GLOBAL" = "1" ]; then found="$glob"; else found="$TARGET_DIR/$proj"; fi
      break
    fi
  done
  if [ -z "$found" ]; then
    echo "error: unknown agent '$want' (see --list)" >&2
    exit 1
  fi
  idx=-1
  for i in "${!DESTS[@]}"; do [ "${DESTS[$i]}" = "$found" ] && idx=$i; done
  if [ "$idx" -ge 0 ]; then
    DEST_LABELS[$idx]="${DEST_LABELS[$idx]}, $want"
  else
    DESTS+=("$found")
    DEST_LABELS+=("$want")
  fi
done

echo
for i in "${!DESTS[@]}"; do
  dest="${DESTS[$i]}"
  echo "${DEST_LABELS[$i]} -> ${dest/#$HOME/~}"
  for skill in "${SKILL_NAMES[@]}"; do
    if [ "$DRY_RUN" = "1" ]; then
      echo "  would install $skill"
    else
      mkdir -p "$dest"
      rm -rf "${dest:?}/$skill"
      cp -R "$SKILLS_SRC/$skill" "$dest/$skill"
      echo "  installed $skill"
    fi
  done
done

echo
if [ "$DRY_RUN" = "1" ]; then
  echo "Dry run - nothing was written."
else
  echo "Done. Restart your agent, then ask it to \"scaffold the project docs\"."
  echo "Claude Code users: the plugin is usually a better fit than a raw copy —"
  echo "  /plugin marketplace add melconcoast/code-idea"
fi
