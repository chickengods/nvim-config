return {
  'kevinhwang91/nvim-ufo',
  dependencies = {
    'kevinhwang91/promise-async',
  },
  event = 'VeryLazy',
  opts = {
    provider_selector = function()
      return { 'treesitter', 'indent' }
    end,
  },
  config = function(_, opts)
    -- Setup UFO
    require('ufo').setup(opts)

    -- Set fold options
    vim.o.foldcolumn = '1' -- Show fold column
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    -- Keymaps
    vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open all folds' })
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds, { desc = 'Close all folds' })
    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds, { desc = 'Open folds except kinds' })
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith, { desc = 'Close folds with' })
    vim.keymap.set('n', 'K', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if not winid then
        -- Use LSP hover if no fold found
        vim.lsp.buf.hover()
      end
    end, { desc = 'Peek fold or hover' })
  end,
}
