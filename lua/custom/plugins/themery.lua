return {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      local themes = require('custom.themes')
      require("themery").setup({
        themes = themes.get_themes(),
        livePreview = true, -- Apply theme while picking. Default to true.
      })
    end
  }
