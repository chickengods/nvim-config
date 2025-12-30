return {
  'smjonas/inc-rename.nvim',
  config = function()
    require('inc_rename').setup()
  end,
  keys = {
    {
      '<leader>rn',
      function()
        return ':IncRename ' .. vim.fn.expand '<cword>'
      end,
      desc = 'LSP Rename',
      expr = true,
      mode = 'n',
    },
  },
}
