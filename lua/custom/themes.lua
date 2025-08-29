-- Theme definitions for themery
local M = {}

-- All available themes for themery
M.themes = {
  -- Rose Pine variants
  'rose-pine',
  'rose-pine-main',
  'rose-pine-moon',
  'rose-pine-dawn',

  -- Tokyo Night variants
  'tokyonight',
  'tokyonight-night',
  'tokyonight-storm',
  'tokyonight-day',
  'tokyonight-moon',

  -- Catppuccin variants
  'catppuccin',
  'catppuccin-latte',
  'catppuccin-frappe',
  'catppuccin-macchiato',
  'catppuccin-mocha',

  -- Nightfox variants
  'nightfox',
  'dayfox',
  'dawnfox',
  'duskfox',
  'nordfox',
  'terafox',
  'carbonfox',

  -- Dracula
  'dracula',
  'dracula-soft',

  -- Mini.nvim themes
  'minicyan',
  'minischeme',
  'randomhue',

  -- Built-in Neovim themes
  'blue',
  'darkblue',
  'default',
  'delek',
  'desert',
  'elflord',
  'evening',
  'habamax',
  'industry',
  'koehler',
  'lunaperche',
  'morning',
  'murphy',
  'pablo',
  'peachpuff',
  'quiet',
  'retrobox',
  'ron',
  'shine',
  'slate',
  'sorbet',
  'torte',
  'unokai',
  'vim',
  'wildcharm',
  'zaibatsu',
  'zellner',
}

-- Export themes list for use by other modules
M.get_themes = function()
  return M.themes
end

return M

