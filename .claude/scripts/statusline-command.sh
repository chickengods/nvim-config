#!/bin/bash
set -e

input=$(cat)

# Context window progress bar
pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
pct_int=${pct%.*}
: "${pct_int:=0}"
filled=$((pct_int / 10))
empty=$((10 - filled))

if [ "$pct_int" -ge 90 ]; then
  bar_color="\033[0;31m"
elif [ "$pct_int" -ge 70 ]; then
  bar_color="\033[0;33m"
else
  bar_color="\033[0;32m"
fi
reset="\033[0m"
cyan="\033[0;36m"
red="\033[0;31m"
yellow="\033[0;33m"
blue="\033[0;34m"

bar=""
for ((i=0; i<filled; i++)); do bar+="█"; done
for ((i=0; i<empty; i++)); do bar+="░"; done

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // .model.id // "?"' | sed 's/Claude //' | cut -c1-16)

# Git branch + dirty state (fast, no diff-index)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // "."')
dir_name=$(basename "$cwd")
branch=""
dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$branch" ] && ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null; then
    dirty=" ✗"
  fi
fi

# Assemble output
if [ -n "$branch" ]; then
  git_part=" $(printf "${blue}git:(${red}%s${blue})${yellow}%s${reset}" "$branch" "$dirty")"
else
  git_part=""
fi

printf "${cyan}%s${reset}%s | %s | $(printf "${bar_color}")%s${reset} %s%%" \
  "$dir_name" \
  "$git_part" \
  "$model" \
  "$bar" \
  "$pct_int"
