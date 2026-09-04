return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown', 'Avante', 'AvanteInput', 'codecompanion', 'copilot-chat' },
  cmd = { 'RenderMarkdown' },
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
  keys = {
    {
      '<leader>tm',
      '<cmd>RenderMarkdown toggle<CR>',
      desc = '[T]oggle [M]arkdown render',
    },
  },
  opts = {
    file_types = { 'markdown', 'Avante', 'AvanteInput', 'codecompanion', 'copilot-chat' },
  },
}
