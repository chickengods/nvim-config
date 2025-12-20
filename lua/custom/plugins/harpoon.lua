return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup()

    vim.keymap.set('n', '<leader>z', function()
      harpoon:list():add()
    end, { noremap = true, desc = 'add file to harpoon' })

    for i = 0, 9 do
      vim.keymap.set('n', '<leader>' .. tostring(i), function()
        harpoon:list():select(i)
      end, { noremap = true, desc = 'which_key_ignore' })
    end

    vim.keymap.set('n', '<leader>o', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { noremap = true, desc = 'Open harpoon window' })
  end,
}
