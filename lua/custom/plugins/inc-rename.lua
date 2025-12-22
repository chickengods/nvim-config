return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  keys = {
    {
      '<leader>rn',
      function()
        local word = vim.fn.expand '<cword>'
        vim.cmd('IncRename ' .. word)
      end,
      desc = 'Incremental rename',
    },
  },
  config = function()
    require('inc_rename').setup {
      input_buffer_type = 'dressing', -- Use dressing.nvim if available, otherwise default
    }
  end,
}
