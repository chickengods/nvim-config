return {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
  },
  event = { 'CmdlineEnter' },
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()',
  config = function()
    require('go').setup {
      -- Disable LSP config since we're using nvim-lspconfig
      lsp_cfg = false,
      lsp_keymaps = false,
      -- Disable inlay hints here, gopls handles them
      lsp_inlay_hints = {
        enable = false,
      },
      -- Test runner
      run_in_floaterm = true,
      -- Disable formatter/linter, conform.nvim handles formatting
      formatter = false,
      linter = false,
    }

    -- Keymaps for go.nvim features
    vim.keymap.set('n', '<leader>gj', '<cmd>GoTagAdd json<cr>', { desc = 'Add JSON tags' })
    vim.keymap.set('n', '<leader>gy', '<cmd>GoTagAdd yaml<cr>', { desc = 'Add YAML tags' })
    vim.keymap.set('n', '<leader>gi', '<cmd>GoImpl<cr>', { desc = 'Implement interface' })
    vim.keymap.set('n', '<leader>ge', '<cmd>GoIfErr<cr>', { desc = 'Add if err block' })
    vim.keymap.set('n', '<leader>gf', '<cmd>GoFillStruct<cr>', { desc = 'Fill struct' })
    vim.keymap.set('n', '<leader>gF', '<cmd>GoFillSwitch<cr>', { desc = 'Fill switch' })
    vim.keymap.set('n', '<leader>gc', '<cmd>GoCoverage<cr>', { desc = 'Show test coverage' })
    vim.keymap.set('n', '<leader>gC', '<cmd>GoCoverageClear<cr>', { desc = 'Clear test coverage' })
  end,
}
