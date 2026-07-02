#!/bin/bash
set -euo pipefail

# Stop hook: ask the agent whether this turn produced anything worth porting
# to the feature-docs system. Loop guard via stop_hook_active.

input=$(cat)
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

if [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

reason=$(cat <<'EOF'
Before stopping: decide if anything from this turn should be ported to the
feature-docs system under $HOME/agent_docs/.

If yes (PR/milestone state moved, design decision made, useful finding,
ad-hoc work worth journaling) → invoke the port-to-feature-docs skill now,
then stop.

If no (chit-chat, a question answered without doing work, pure read-only
research with no useful finding, planning that didn't conclude) → just stop.
EOF
)

jq -n --arg reason "$reason" '{
  "decision": "block",
  "reason": $reason,
  "systemMessage": "📓 Doc-sync check"
}'
exit 0
