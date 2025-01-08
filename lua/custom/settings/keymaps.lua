-----------------
-- KEY MAPPIGNS
-----------------

vim.g.mapleader = ' '
vim.g.maplocalleader = ' ' -- not using local leader

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.api.nvim_set_keymap('n', '<Leader>cn', '<cmd>cnext<CR>', { noremap = true, silent = true, desc = 'move to [n]ext quickfix' })
vim.api.nvim_set_keymap('n', '<Leader>cp', '<cmd>cprev<CR>', { noremap = true, silent = true, desc = 'move to [p]reviosu quickfix' })
vim.api.nvim_set_keymap('n', '<Leader>cc', '<cmd>cclose<CR>', { noremap = true, silent = true, desc = '[c]lose quickfix' })

vim.api.nvim_set_keymap('n', '<Leader>ln', '<cmd>lnext<CR>', { noremap = true, silent = true, desc = 'move to [n]ext location list' })
vim.api.nvim_set_keymap('n', '<Leader>lp', '<cmd>lprev<CR>', { noremap = true, silent = true, desc = 'move to [p]reviosu location lsit' })
vim.api.nvim_set_keymap('n', '<Leader>lc', '<cmd>lclose<CR>', { noremap = true, silent = true, desc = '[c]lsoe location lsit' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('i', 'jk', '<Esc>', { desc = 'leave insert mode' })
vim.keymap.set('i', 'kj', '<Esc>', { desc = 'leave insert mode' })
