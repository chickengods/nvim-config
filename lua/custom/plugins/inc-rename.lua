return {
  'smjonas/inc-rename.nvim',
  event = 'VeryLazy', -- Load early so it's available when LSP attaches
  config = function()
    require('inc_rename').setup {
      input_buffer_type = 'dressing', -- Use dressing.nvim if available, otherwise default
    }
    -- Keymap is set up in nvim-lspconfig.lua's LspAttach autocmd
  end,
}
