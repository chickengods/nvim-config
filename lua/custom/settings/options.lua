-----------------
-- BASE SETTINGS
-----------------

-- Visual Enhancements
vim.g.have_nerd_font = true -- Enable nerd font support
vim.opt.cursorline = false -- Disable highlighting of current line
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { -- Define how to show invisible characters
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}
vim.opt.signcolumn = 'yes' -- Always show the signcolumn

-- Line Numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.number = true -- Show current line number

-- Search and Replace
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Override ignorecase if search has uppercase
vim.opt.inccommand = 'split' -- Show preview of substitutions in split

-- Editor Behavior
vim.opt.breakindent = true -- Maintain indent when wrapping lines
vim.opt.showmode = false -- Don't show mode (use statusline instead)
vim.opt.undofile = true -- Persistent undo history
vim.opt.updatetime = 250 -- Faster update time for CursorHold events
vim.opt.timeoutlen = 300 -- Time to wait for mapped sequences

-- Window Management
vim.opt.splitright = true -- New vertical splits open to the right
vim.opt.splitbelow = true -- New horizontal splits open below

-- Editor Behavior
vim.opt.shiftwidth = 2 -- Number of spaces for auto-indent
vim.opt.softtabstop = 2 -- Number of spaces for <Tab> key
vim.opt.scrolloff = 8 -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor

-- Search
vim.opt.hlsearch = false -- Don't highlight search results
vim.opt.incsearch = true -- Incremental search

-- Visual
vim.opt.termguicolors = true -- Enable 24-bit RGB color
vim.opt.wrap = false -- Don't wrap long lines

-- Completion
vim.opt.completeopt = { -- Better completion experience
  'menuone',
  'noselect',
  'noinsert',
}
vim.opt.wildmode = { -- Better command-line completion
  'longest',
  'list',
  'full',
}

-- Performance
vim.opt.lazyredraw = true -- Don't redraw during macros

-- Backups
-- vim.opt.backup = false
-- vim.opt.writebackup = false
-- vim.opt.swapfile = true

-- Mouse
vim.opt.mouse = 'a' -- Enable mouse in all modes
