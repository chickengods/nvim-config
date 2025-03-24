return {
  'kbwo/vim-shareedit',
  config = function()
    vim.keymap.set('n', '<leader>se', '<cmd>ShareEditStart<cr>', { desc = '[S]hare[E]dit' })
  end,
}
