# Portable development setup

Reproducible macOS setup for Ghostty, Neovim, tmux, Go, and the command-line tools used by this Neovim configuration.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/chickengods/nvim-config/master/install.sh | bash
```

The installer is idempotent on a clean checkout. An existing `~/.tmux.conf` is timestamped before replacement, and a modified or unexpected Neovim checkout is left untouched.

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
- The latest stable Ghostty, plus Neovim, tmux, and TPM
- Go and Node.js for configured language tooling
- ripgrep, fzf, and lazygit for configured Neovim features

## Neovim environment

The default `.nvim-env` selects the portable `personal` configuration:

```sh
NVIM_ENV=personal
```

Override a single launch with `NVIM_ENV=work nvim` when a work-specific profile is available.

## Repository layout

- `init.lua` and `lua/custom/` — Neovim configuration
- `.tmux.conf` — tmux configuration with current-directory windows and splits
- `install.sh` and `Brewfile` — machine bootstrap
