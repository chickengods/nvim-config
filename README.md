# Portable development setup

Reproducible macOS setup for Ghostty, Neovim, tmux, zsh, and local agent workflows.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/chickengods/nvim-config/master/install.sh | bash
```

The installer is idempotent on a clean checkout. Existing `~/.zshrc`, `~/.tmux.conf`, and agent files are timestamped before replacement. It stops instead of overwriting a modified Neovim checkout.

Preview all commands without changing the machine:

```sh
curl -fsSL https://raw.githubusercontent.com/chickengods/nvim-config/master/install.sh | bash -s -- --dry-run
```

Test another branch:

```sh
DEV_SETUP_BRANCH=my-branch bash install.sh --dry-run
```

## Installed tools

- Homebrew and the packages in `Brewfile`
- Ghostty, Neovim, tmux, TPM, and Oh My Zsh
- Go, Node.js, Deno, ripgrep, fzf, lazygit, direnv, and rbenv
- Cursor CLI
- Feature workflow skills, references, hooks, and `~/agent_docs/` directories

The setup never copies API keys, tokens, machine-specific paths, or private project data. Authentication remains interactive:

```sh
gh auth login
cursor-agent login
```

## Neovim environment

The default `.nvim-env` selects the portable `personal` configuration:

```sh
NVIM_ENV=personal
```

Override a single launch with `NVIM_ENV=work nvim` when a work-specific profile is available.

## Repository layout

- `init.lua` and `lua/custom/` — Neovim configuration
- `.tmux.conf` — tmux configuration with current-directory windows and splits
- `dotfiles/zshrc` — portable interactive shell configuration
- `.claude/` — versioned agent workflow source
- `install.sh` and `Brewfile` — machine bootstrap
