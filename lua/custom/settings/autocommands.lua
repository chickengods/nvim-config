-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Add gopls performance monitoring command
vim.api.nvim_create_user_command('GoplsMonitor', function()
  vim.cmd('!bash ~/.config/nvim/scripts/gopls-monitor.sh')
end, { desc = 'Monitor gopls performance and memory usage' })

-- Add gopls restart command for when memory gets too high
vim.api.nvim_create_user_command('GoplsRestart', function()
  vim.cmd('LspRestart gopls')
  print('gopls restarted - this may take a moment to reinitialize')
end, { desc = 'Restart gopls to free memory' })

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = '*',
})
