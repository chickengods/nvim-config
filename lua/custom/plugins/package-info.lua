return {
  'vuki656/package-info.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  event = 'BufRead package.json',
  config = function()
    require('package-info').setup {
      colors = {
        up_to_date = '#3C4048',
        outdated = '#d19a66',
      },
      icons = {
        enable = true,
        style = {
          up_to_date = '  ',
          outdated = '  ',
        },
      },
      autostart = true,
      hide_up_to_date = false,
      hide_unstable_versions = false,
    }

    -- Keymaps
    vim.keymap.set('n', '<leader>ns', require('package-info').show, { desc = 'Show package versions', silent = true })
    vim.keymap.set('n', '<leader>nc', require('package-info').hide, { desc = 'Hide package versions', silent = true })
    vim.keymap.set('n', '<leader>nt', require('package-info').toggle, { desc = 'Toggle package versions', silent = true })
    vim.keymap.set('n', '<leader>nu', require('package-info').update, { desc = 'Update package', silent = true })
    vim.keymap.set('n', '<leader>nd', require('package-info').delete, { desc = 'Delete package', silent = true })
    vim.keymap.set('n', '<leader>ni', require('package-info').install, { desc = 'Install package', silent = true })
    vim.keymap.set('n', '<leader>np', require('package-info').change_version, { desc = 'Change package version', silent = true })
  end,
}
