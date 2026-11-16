#!/usr/bin/env bash
# Install the grill-with-stories and make-a-story skills by copying (or symlinking) them into agent skill folders.
# Usage: scripts/install.sh [--claude] [--agy] [--project <dir>] [--link] [--uninstall]
# With no target flag, installs globally for both Claude Code and Antigravity. Needs mattpocock/skills `grilling`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../skills" && pwd)"
NAMES=("grill-with-stories" "make-a-story")
CLAUDE=0; AGY=0; LINK=0; UNINSTALL=0; PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --claude) CLAUDE=1 ;;
    --agy) AGY=1 ;;
    --link) LINK=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --project) shift; PROJECT="${1:?--project needs a directory}" ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
[ $CLAUDE -eq 0 ] && [ $AGY -eq 0 ] && CLAUDE=1 && AGY=1

targets=()
if [ -n "$PROJECT" ]; then
  [ $CLAUDE -eq 1 ] && targets+=("$PROJECT/.claude/skills")
  [ $AGY -eq 1 ] && targets+=("$PROJECT/.agents/skills")
else
  [ $CLAUDE -eq 1 ] && targets+=("$HOME/.claude/skills")
  # Antigravity documents ~/.gemini/config/skills; the skills CLI writes to antigravity-cli/skills.
  [ $AGY -eq 1 ] && targets+=("$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills")
fi

for dir in "${targets[@]}"; do
  for name in "${NAMES[@]}"; do
    src="$ROOT/$name"
    dest="$dir/$name"
    rm -rf "$dest"
    if [ $UNINSTALL -eq 1 ]; then echo "removed  $dest"; continue; fi
    mkdir -p "$dir"
    if [ $LINK -eq 1 ]; then ln -s "$src" "$dest"; echo "linked   $dest -> $src"
    else cp -R "$src" "$dest"; echo "copied   $dest"; fi
  done
done
[ $UNINSTALL -eq 1 ] && exit 0

# grill-with-stories builds on mattpocock/skills `grilling`. Warn (don't fail) if it isn't visible.
found=0
for dir in "${targets[@]}" "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.gemini/config/skills" "$HOME/.gemini/antigravity-cli/skills"; do
  [ -f "$dir/grilling/SKILL.md" ] && found=1 && break
done
if [ $found -eq 0 ] && [ -d "$HOME/.claude/plugins" ] && find "$HOME/.claude/plugins" -path '*/grilling/SKILL.md' -print -quit 2>/dev/null | grep -q .; then
  found=1
fi
if [ $found -eq 0 ]; then
  echo "" >&2
  echo "warning: no 'grilling' skill found. /grill-with-stories needs it. Install mattpocock/skills:" >&2
  echo "  npx skills add mattpocock/skills --skill grilling -g -a claude-code -a antigravity-cli -y" >&2
fi
