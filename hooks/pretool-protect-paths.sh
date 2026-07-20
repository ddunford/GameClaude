#!/usr/bin/env bash
# PreToolUse / Edit|Write — deny writes to secrets and frozen paths.
set -euo pipefail
input="$(cat)"
path="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

deny() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "\"$1\""
  exit 0
}

case "$path" in
  *".env"|*".env."*|*"secrets/"*|*"credentials"*|*".pem"|*"id_rsa"*|*".env.services"*)
    deny "Refused: secrets/credentials are never edited or committed. Use env-var names, not values." ;;
  *"/_archive/"*)
    deny "Refused: _archive/ is frozen trial-1 history — read-only. Corrections go to the live docs, not the archive." ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}\n'
