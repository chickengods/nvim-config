return {
  'smjonas/inc-rename.nvim',
  event = 'LspAttach', -- Load when LSP attaches
  config = function()
    require('inc_rename').setup {
      input_buffer_type = 'dressing', -- Use dressing.nvim if available, otherwise default
    }

    -- Set up keymap after plugin loads
    vim.keymap.set('n', '<leader>rn', function()
      return ':IncRename ' .. vim.fn.expand '<cword>'
    end, { expr = true, desc = 'LSP: Incremental rename' })
  end,
}
