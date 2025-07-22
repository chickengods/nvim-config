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

vim.keymap.set('v', '<Leader>y', '"+y', { desc = 'yank to clipboard' })
vim.keymap.set('v', '<Leader>p', '"0p', { desc = 'paste from reg 0' })
vim.keymap.set('v', '<Leader>p', '"0p', { desc = 'paste from reg 0' })

-- custom function mapping
local function go_test_file_toggle()
  local file = vim.fn.expand '%:t'
  local path = vim.fn.expand '%:p:h'

  if not file:match '.go' then
    print 'Not a go file'
    return
  end

  if file:match '_test.go' then
    file = file:gsub('_test.go', '.go')
  else
    file = file:gsub('.go', '_test.go')
  end

  local file_path = path .. '/' .. file
  if vim.fn.filereadable(file_path) == 1 then
    vim.cmd('e ' .. file_path)
  else
    print('Go test file not found:' .. file_path)
  end
end

vim.keymap.set('n', '<leader>gt', function()
  go_test_file_toggle()
end, { noremap = true, silent = true, desc = 'Toggle test file' })

-- gp.lua

local function keymapOptions(desc)
  return {
    noremap = true,
    silent = true,
    nowait = true,
    desc = 'GPT prompt ' .. desc,
  }
end

-- from a terminal buffer, move like in normal mode
vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]])
vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]])
