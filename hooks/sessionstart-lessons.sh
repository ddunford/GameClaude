#!/usr/bin/env bash
# SessionStart — inject the studio's hard-won lessons into context.
set -euo pipefail
cat >/dev/null   # consume the event
dir="${CLAUDE_PROJECT_DIR:-.}"
out=""
[ -f "$dir/.claude/lessons.md" ] && out="$out$(cat "$dir/.claude/lessons.md")"$'\n'
[ -f "$dir/lessons.md" ] && out="$out$(cat "$dir/lessons.md")"$'\n'
if [ -n "$out" ]; then
  # emit as additionalContext (JSON-escaped)
  esc="$(printf '%s' "$out" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '""')"
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":%s}}\n' "$esc"
fi
