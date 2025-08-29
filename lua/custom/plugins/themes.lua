-- Theme plugin configurations
return {
  -- Rose Pine
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      vim.cmd 'colorscheme rose-pine-moon'
    end,
  },
  
  -- Tokyo Night
  {
    "folke/tokyonight.nvim",
  },
  
  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
  
  -- Nightfox
  {
    "EdenEast/nightfox.nvim",
  },
  
  -- Dracula
  {
    "Mofiqul/dracula.nvim",
  },
}
