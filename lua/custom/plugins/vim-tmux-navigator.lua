-- vim-tmux-navigator: Seamless navigation between tmux panes and vim splits
return {
  'christoomey/vim-tmux-navigator',
  lazy = false, -- Load immediately for navigation to work
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<cr>', desc = 'Navigate Left' },
    { '<C-j>', '<cmd>TmuxNavigateDown<cr>', desc = 'Navigate Down' },
    { '<C-k>', '<cmd>TmuxNavigateUp<cr>', desc = 'Navigate Up' },
    { '<C-l>', '<cmd>TmuxNavigateRight<cr>', desc = 'Navigate Right' },
    { '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', desc = 'Navigate Previous' },
  },
  config = function()
    -- Disable default mappings to avoid conflicts
    vim.g.tmux_navigator_no_mappings = 1

    -- Enable navigation in terminal mode for Claude Code and other terminal buffers
    vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true, desc = 'Navigate Left' })
    vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true, desc = 'Navigate Down' })
    vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true, desc = 'Navigate Up' })
    vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Navigate Right' })
    vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', { silent = true, desc = 'Navigate Previous' })

    -- Terminal mode mappings for Claude Code terminal
    vim.keymap.set('t', '<C-h>', '<cmd>TmuxNavigateLeft<cr>', { silent = true, desc = 'Navigate Left' })
    vim.keymap.set('t', '<C-j>', '<cmd>TmuxNavigateDown<cr>', { silent = true, desc = 'Navigate Down' })
    vim.keymap.set('t', '<C-k>', '<cmd>TmuxNavigateUp<cr>', { silent = true, desc = 'Navigate Up' })
    vim.keymap.set('t', '<C-l>', '<cmd>TmuxNavigateRight<cr>', { silent = true, desc = 'Navigate Right' })
    vim.keymap.set('t', '<C-\\>', '<cmd>TmuxNavigatePrevious<cr>', { silent = true, desc = 'Navigate Previous' })
  end,
}
