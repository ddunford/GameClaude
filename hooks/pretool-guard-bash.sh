#!/usr/bin/env bash
# PreToolUse / Bash — deny catastrophic or forbidden commands.
# Reads the tool-call event JSON on stdin; emits a permission verdict.
set -euo pipefail
input="$(cat)"
cmd="$(printf '%s' "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p')"

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' \
    "\"$1\""
  exit 0
}

# --- Catastrophic filesystem / repo ---
case "$cmd" in
  *"rm -rf /"*|*"rm -rf ~"*|*":(){:|:&};:"*|*"mkfs"*|*"dd if="*"of=/dev/"*) deny "Refused: catastrophic command." ;;
  *"git push"*"--force"*|*"git push -f"*)                deny "Refused: force-push. Push normally, or ask the owner." ;;
  *"git reset --hard"*"origin/"*)                        deny "Refused: hard reset to remote can discard work. Confirm with the owner." ;;
esac

# --- UE studio safety (doctrine / tooling-ue) ---
case "$cmd" in
  *"taskkill"*"UnrealEditor"*|*"taskkill //IM UnrealEditor"*)
    deny "Refused: never taskkill UnrealEditor by image name — the owner's editor and any -server run share it. Shut a -server run from inside (quit), or kill one captured PID." ;;
  *"taskkill //F"*)
    deny "Refused: force-killing by name/tree can take the owner's editor with it. Kill one captured PID only." ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}\n'
