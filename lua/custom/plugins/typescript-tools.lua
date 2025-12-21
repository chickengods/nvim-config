return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  ft = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  opts = {
    -- Improve performance by exposing file references via handlers
    expose_as_code_action = 'all',
    -- Enable completion for `import` statements
    complete_function_calls = true,
    -- Include diagnostics for `import` and `export` statements
    include_completions_with_insert_text = true,
  },
  config = function(_, opts)
    require('typescript-tools').setup(opts)
  end,
}
