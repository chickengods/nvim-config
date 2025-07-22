return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    gitbrowse = {
      enabled = true,
      url_patterns = {
        ['github%.plaid%.com'] = {
          branch = '/tree/{branch}',
          file = '/blob/{branch}/{file}#L{line_start}-L{line_end}',
          fileNoLines = '/blob/{branch}/{file}',
          permalink = '/-/blob/{commit}/{file}#L{line_start}-L{line_end}',
          commit = '/commit/{commit}',
        },
      },
    },
  },
  keys = {
    {
      '<leader>gb',
      function()
        local snacks = require 'snacks'

        -- Check if we're in oil.nvim
        if vim.bo.filetype == 'oil' then
          local oil = require 'oil'
          local current_dir = oil.get_current_dir()
          if current_dir then
            -- Convert to relative path from git root
            local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
            if git_root and git_root ~= '' then
              local relative_path = current_dir:gsub(git_root .. '/', '')
              -- Generate URL for directory browsing
              snacks.gitbrowse {
                what = 'branch',
                branch = 'master', -- Force use of master branch for directory links
                open = function(url)
                  -- Add directory path to URL if not root
                  if relative_path ~= '' and relative_path ~= '.' then
                    url = url .. '/' .. relative_path
                  end
                  vim.fn.setreg('+', url)
                  vim.notify('Git URL copied to clipboard: ' .. url, vim.log.levels.INFO)
                end,
              }
              return
            end
          end
        end

        -- For files, let gitbrowse handle everything but override the open function
        -- Use different 'what' based on mode to control line numbers
        local mode = vim.fn.mode()
        local what = (mode == 'v' or mode == 'V' or mode == '\22') and 'file' or 'fileNoLines'

        local opts = {
          what = what,
          branch = 'master',
          open = function(url)
            vim.fn.setreg('+', url)
            vim.notify('Git URL copied to clipboard: ' .. url, vim.log.levels.INFO)
          end,
        }

        snacks.gitbrowse(opts)
      end,
      desc = 'Git Browse to clipboard',
      mode = { 'n', 'v' },
    },
  },
}
