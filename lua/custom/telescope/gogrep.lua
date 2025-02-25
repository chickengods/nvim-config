local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local make_entry = require 'telescope.make_entry'
local conf = require('telescope.config').values

local M = {}

local live_go_grep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == '' then
        return nil
      end

      local args = { 'rg' }
      table.insert(args, '-e')
      table.insert(args, prompt)

      table.insert(args, '-g')
      table.insert(args, '*.go')

      table.insert(args, '-g')
      table.insert(args, '!*_test.go')

      table.insert(args, '-g')
      table.insert(args, '!*.pb.go')

      table.insert(args, '-g')
      table.insert(args, '!mock_*')

      ---@diagnostic disable-next-line: deprecated
      return vim.tbl_flatten {
        args,
        { '--color=never', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case' },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = 'Go Grep',
      finder = finder,
      previewer = conf.grep_previewer(opts),
      sorter = require('telescope.sorters').empty(),
    })
    :find()
end

M.setup = function()
  vim.keymap.set('n', '<leader>so', live_go_grep, { desc = '[S]earch by g[o] files' })
end

return M
