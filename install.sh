#!/usr/bin/env bash

set -euo pipefail

repo_url="${DEV_SETUP_REPO_URL:-https://github.com/chickengods/nvim-config.git}"
repo_branch="${DEV_SETUP_BRANCH:-master}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
nvim_dir="$config_home/nvim"
backup_suffix="backup.$(date +%Y%m%d%H%M%S)"
dry_run=false

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

run() {
  if "$dry_run"; then
    printf 'run:'
    printf ' %q' "$@"
    printf '\n'
    return
  fi
  "$@"
}

run_shell() {
  if "$dry_run"; then
    printf 'run: %s\n' "$1"
    return
  fi
  /bin/bash -c "$1"
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    *) fail "unknown option: $arg" ;;
  esac
done

[[ "$(uname -s)" == "Darwin" ]] || fail "this bootstrap currently supports macOS"

load_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  local candidate
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      eval "$("$candidate" shellenv)"
      return
    fi
  done
}

install_brew() {
  load_brew
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  run_shell "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  if ! "$dry_run"; then
    load_brew
    command -v brew >/dev/null 2>&1 || fail "Homebrew installed but is not available"
  fi
}

install_repo() {
  run mkdir -p "$config_home"

  if [[ ! -e "$nvim_dir" ]]; then
    run git clone --branch "$repo_branch" "$repo_url" "$nvim_dir"
    return
  fi

  [[ -d "$nvim_dir/.git" ]] || fail "$nvim_dir exists and is not a Git checkout"
  [[ -z "$(git -C "$nvim_dir" status --porcelain)" ]] || fail "$nvim_dir has local changes"

  local current_branch origin_url
  origin_url="$(git -C "$nvim_dir" remote get-url origin)"
  [[ "$origin_url" == "$repo_url" ]] || fail "$nvim_dir uses origin $origin_url, expected $repo_url"

  current_branch="$(git -C "$nvim_dir" branch --show-current)"
  [[ "$current_branch" == "$repo_branch" ]] || fail "$nvim_dir is on $current_branch, expected $repo_branch"

  run git -C "$nvim_dir" pull --ff-only origin "$repo_branch"
}

backup_and_link() {
  local source=$1
  local target=$2

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    run mv "$target" "$target.$backup_suffix"
  fi

  run ln -s "$source" "$target"
}

install_tmux() {
  if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    run mkdir -p "$HOME/.tmux/plugins"
    run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi

  backup_and_link "$nvim_dir/.tmux.conf" "$HOME/.tmux.conf"
}

verify_command() {
  local command_name=$1
  if "$dry_run"; then
    return
  fi
  command -v "$command_name" >/dev/null 2>&1 || fail "$command_name is not available"
}

install_brew
run brew install git
install_repo
run brew update
run brew bundle --file "$nvim_dir/Brewfile"
install_tmux

if [[ ! -e "$nvim_dir/.nvim-env" ]]; then
  run cp "$nvim_dir/.nvim-env.example" "$nvim_dir/.nvim-env"
fi

run "$HOME/.tmux/plugins/tpm/bin/install_plugins"
run nvim --headless '+Lazy! sync' +qa

for command_name in brew git nvim tmux rg fzf node go lazygit; do
  verify_command "$command_name"
done

if ! "$dry_run"; then
  brew list --cask ghostty >/dev/null 2>&1 || fail "Ghostty is not installed"
fi

printf '\nSetup complete.\n'
