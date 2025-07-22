# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Neovim Configuration Architecture

This is a customized Neovim configuration based on kickstart.nvim with extensive personalization for Go development and AI integration.

### Core Structure

**Entry Point**: `init.lua` loads modules in this order:
1. `custom.settings.options` - Core Vim settings
2. `custom.functions.go` - Go-specific utilities  
3. `custom.settings.keymaps` - Global key mappings
4. `custom.settings.autocommands` - Event automation
5. `custom.lazy` - Plugin manager bootstrap
6. `custom.healthcheck` - Configuration validation

**Plugin Organization**: Each plugin has its own file in `lua/custom/plugins/` following lazy.nvim spec format with `config` functions for setup.

### Key Architectural Patterns

**Plugin Configuration Standard**:
```lua
return {
  'plugin/name',
  event = 'BufWritePre', -- or cmd/keys for lazy loading
  config = function()
    -- Setup code here
  end,
}
```

**Custom Functions**: Language-specific utilities are modularized (e.g., `functions/go.lua`) and imported in keymaps for binding.

**Telescope Extensions**: Custom extensions in `lua/custom/telescope/` for specialized search (`multigrep`, `gogrep`).

### Development Workflow

**Plugin Management**: Uses lazy.nvim with auto-installation. Add new plugins by creating files in `lua/custom/plugins/`.

**LSP Configuration**: Handled through `nvim-lspconfig.lua` with Mason for server management. Language servers auto-install on first use.

**Formatting**: Conform.nvim provides format-on-save with language-specific formatters configured in `conform.lua`.

**Go Development**: Specialized setup with custom functions for test running, error navigation, and development workflow in `functions/go.lua`.

### AI Integration

Multiple AI providers configured:
- **Avante**: Main AI coding assistant with Claude/GPT backends
- **GP.nvim**: ChatGPT integration with custom commands
- **Copilot**: GitHub Copilot with chat support

AI commands use `<C-g>` prefix for consistency across providers.

### Configuration Conventions

- Space as leader key with descriptive mappings
- Event-driven plugin loading for performance
- Rose Pine theme with consistent iconography
- Comprehensive clipboard and quickfix management
- Custom autocommands for Go file handling and LSP setup