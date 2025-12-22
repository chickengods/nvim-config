return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  keys = {
    {
      '<leader>rn',
      function()
        return ':IncRename ' .. vim.fn.expand '<cword>'
      end,
      expr = true,
      desc = 'Incremental rename',
    },
  },
  config = function()
    require('inc_rename').setup {
      input_buffer_type = 'dressing', -- Use dressing.nvim if available, otherwise default
    }
  end,
}
