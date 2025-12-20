return {
  'ibhagwan/fzf-lua',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    local fzf = require 'fzf-lua'

    -- Setup with telescope profile for familiar look/feel
    fzf.setup {
      'telescope',
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        border = 'rounded',
        preview = {
          layout = 'flex',
          flip_columns = 120,
        },
      },
      -- Enable glob separator for multi-grep functionality
      -- Usage: "search_term -- *.go *.lua" to search in specific file types
      grep = {
        rg_glob = true,
        glob_flag = '--iglob',
        glob_separator = '%s%-%-',
      },
      files = {
        -- Use ivy-like theme for file picker
        winopts = {
          height = 0.40,
          width = 1.0,
          row = 1.0,
        },
      },
    }

    -- Register fzf-lua as UI select handler (replaces telescope-ui-select)
    fzf.register_ui_select()

    -- Keymaps migrated from telescope
    vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', fzf.files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
    vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', fzf.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })

    -- Search in current buffer
    vim.keymap.set('n', '<leader>/', function()
      fzf.lgrep_curbuf {
        winopts = {
          height = 0.40,
          width = 1.0,
          row = 1.0,
        },
      }
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- Live grep in open files
    vim.keymap.set('n', '<leader>s/', function()
      fzf.live_grep {
        grep_open_files = true,
        prompt = 'Live Grep in Open Files> ',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Search Neovim config files
    vim.keymap.set('n', '<leader>sn', function()
      fzf.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Multi-grep with glob support (replaces custom multigrep extension)
    -- Usage: Type "search_term -- *.go *.lua" to filter by file patterns
    vim.keymap.set('n', '<leader>sm', function()
      fzf.live_grep {
        prompt = 'Multi Grep> ',
      }
    end, { desc = '[S]earch by [M]ulti-Grep (use -- for globs)' })

    -- Go-specific grep (replaces custom gogrep extension)
    vim.keymap.set('n', '<leader>so', function()
      fzf.live_grep {
        prompt = 'Go Grep> ',
        cmd = "rg --column --line-number --no-heading --color=always --smart-case "
          .. "--iglob '*.go' "
          .. "--iglob '!*_test.go' "
          .. "--iglob '!*.pb.go' "
          .. "--iglob '!mock_*' "
          .. "--iglob '!*.connect.go' "
          .. "--iglob '!*.perms.go' "
          .. "--iglob '!*.inventory.go'",
      }
    end, { desc = '[S]earch by g[o] files' })
  end,
}
