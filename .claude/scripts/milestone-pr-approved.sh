#!/bin/bash
set -euo pipefail

# UserPromptSubmit hook: detects PR approval phrases during milestone-implement workflow.
# Advances any state file that is enabled + awaiting_review and emits a system message
# to re-invoke the skill. Supports linear mode (.claude/milestone-implement.local.md)
# and stack mode (.claude/milestone-implement-<stack_id>.local.md).

input=$(cat)
user_prompt=$(echo "$input" | jq -r '.user_prompt // ""')
cwd=$(echo "$input" | jq -r '.cwd // "."')

prompt_lower=$(echo "$user_prompt" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

is_approval=false
case "$prompt_lower" in
  "pr is good"*|"pr looks good"*|"lgtm"*|"ship it"*|"pr approved"*|"looks good, next"*|"approve pr"*|"pr is done"*|"next pr"*|"continue to next"*|"pr good"*)
    is_approval=true
    ;;
esac

if [ "$is_approval" != "true" ]; then
  exit 0
fi

shopt -s nullglob
state_files=("$cwd"/.claude/milestone-implement*.local.md)
shopt -u nullglob

if [ ${#state_files[@]} -eq 0 ]; then
  exit 0
fi

messages=()

for STATE_FILE in "${state_files[@]}"; do
  [ -f "$STATE_FILE" ] || continue

  FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
  ENABLED=$(echo "$FRONTMATTER" | grep '^enabled:' | sed 's/enabled: *//')
  AWAITING=$(echo "$FRONTMATTER" | grep '^awaiting_review:' | sed 's/awaiting_review: *//')
  CURRENT_INDEX=$(echo "$FRONTMATTER" | grep '^current_pr_index:' | sed 's/current_pr_index: *//')
  TOTAL_PRS=$(echo "$FRONTMATTER" | grep '^total_prs:' | sed 's/total_prs: *//')
  FEATURE_NAME=$(echo "$FRONTMATTER" | grep '^feature_name:' | sed 's/feature_name: *//')
  MILESTONE_ID=$(echo "$FRONTMATTER" | grep '^milestone_id:' | sed 's/milestone_id: *//')
  STACK_ID=$(echo "$FRONTMATTER" | grep '^stack_id:' | sed 's/stack_id: *//')

  if [ "$ENABLED" != "true" ] || [ "$AWAITING" != "true" ]; then
    continue
  fi

  if [ -n "$STACK_ID" ]; then
    SCOPE_LABEL="feature '${FEATURE_NAME}' milestone ${MILESTONE_ID} stack ${STACK_ID}"
  else
    SCOPE_LABEL="feature '${FEATURE_NAME}' milestone ${MILESTONE_ID}"
  fi

  NEXT_INDEX=$((CURRENT_INDEX + 1))

  if [ "$NEXT_INDEX" -gt "$TOTAL_PRS" ]; then
    sed -i '' "s/^enabled: .*/enabled: false/" "$STATE_FILE"
    sed -i '' "s/^awaiting_review: .*/awaiting_review: false/" "$STATE_FILE"
    if [ -n "$STACK_ID" ]; then
      messages+=("All ${TOTAL_PRS} PRs for ${SCOPE_LABEL} are complete. Stack ${STACK_ID} done. Update STATUS.md accordingly. Other stacks (if any) continue independently.")
    else
      messages+=("All ${TOTAL_PRS} PRs for ${SCOPE_LABEL} are complete. The milestone-implement loop has finished. Update STATUS.md milestone line to [-] (all PRs open, pending merge) or [x] if all are merged.")
    fi
  else
    sed -i '' "s/^current_pr_index: .*/current_pr_index: $NEXT_INDEX/" "$STATE_FILE"
    sed -i '' "s/^awaiting_review: .*/awaiting_review: false/" "$STATE_FILE"
    STATE_REL="${STATE_FILE#$cwd/}"
    messages+=("PR${CURRENT_INDEX} approved for ${SCOPE_LABEL}. State advanced to PR${NEXT_INDEX} of ${TOTAL_PRS}. Before starting the next PR, sync docs for the approved PR (step 9 in the skill). Then invoke /milestone-implement-pipeline to continue with PR${NEXT_INDEX}. The state file at ${STATE_REL} has all the context needed.")
  fi
done

if [ ${#messages[@]} -eq 0 ]; then
  exit 0
fi

combined=$(printf '%s\n\n' "${messages[@]}")
combined="${combined%$'\n\n'}"
jq -n --arg msg "$combined" '{systemMessage: $msg}'
