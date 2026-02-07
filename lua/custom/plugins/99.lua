return {
  'ThePrimeagen/99',
  config = function()
    local _99 = require '99'
    local cwd = vim.uv.cwd()
    local basename = vim.fs.basename(cwd)

    -- Plaid's claude CLI requires --use-bedrock for --print mode
    local PlaidClaudeProvider = setmetatable({}, { __index = _99.Providers.ClaudeCodeProvider })

    function PlaidClaudeProvider._build_command(_, query, request)
      return {
        'claude',
        '--use-bedrock',
        '--dangerously-skip-permissions',
        '--model',
        request.context.model,
        '--print',
        query,
      }
    end

    function PlaidClaudeProvider._get_provider_name()
      return 'PlaidClaudeProvider'
    end

    _99.setup {
      provider = PlaidClaudeProvider,
      model = 'claude-opus-4-6[1m]',

      logger = {
        level = _99.DEBUG,
        path = '/tmp/' .. basename .. '.99.debug',
        print_on_error = true,
      },

      md_files = {
        'CLAUDE.md',
        'AGENTS.md',
      },

      display_errors = true,
    }

    -- Fill in function
    vim.keymap.set('n', '<leader>9f', function()
      _99.fill_in_function()
    end, { desc = 'Fill function' })

    -- Fill in function with prompt
    vim.keymap.set('n', '<leader>9F', function()
      _99.fill_in_function_prompt()
    end, { desc = 'Fill function (prompt)' })

    -- Visual replace
    vim.keymap.set('v', '<leader>9v', function()
      _99.visual()
    end, { desc = 'Visual replace' })

    -- Visual replace with prompt
    vim.keymap.set('v', '<leader>9V', function()
      _99.visual_prompt()
    end, { desc = 'Visual replace (prompt)' })

    -- Stop all requests
    vim.keymap.set({ 'n', 'v' }, '<leader>9s', function()
      _99.stop_all_requests()
    end, { desc = 'Stop requests' })

    -- Logs
    vim.keymap.set('n', '<leader>9l', function()
      _99.view_logs()
    end, { desc = 'View logs' })

    vim.keymap.set('n', '<leader>9[', function()
      _99.prev_request_logs()
    end, { desc = 'Prev request log' })

    vim.keymap.set('n', '<leader>9]', function()
      _99.next_request_logs()
    end, { desc = 'Next request log' })

    -- Request history
    vim.keymap.set('n', '<leader>9q', function()
      _99.previous_requests_to_qfix()
    end, { desc = 'Requests to quickfix' })

    vim.keymap.set('n', '<leader>9c', function()
      _99.clear_previous_requests()
    end, { desc = 'Clear request history' })

    -- Info
    vim.keymap.set('n', '<leader>9i', function()
      _99.info()
    end, { desc = 'Info' })

    -- Model switching
    vim.keymap.set('n', '<leader>9m', function()
      vim.ui.input({ prompt = '99 Model: ' }, function(model)
        if model and model ~= '' then
          _99.set_model(model)
          vim.notify('99 model set to: ' .. model)
        end
      end)
    end, { desc = 'Set model' })
  end,
}
