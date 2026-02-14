local function opencode_call(fn)
  return function()
    local ok, opencode = pcall(require, 'opencode')
    if not ok then
      vim.notify('opencode.nvim is not available', vim.log.levels.ERROR)
      return
    end
    fn(opencode)
  end
end

return {
  'nickjvandyke/opencode.nvim',
  event = 'VeryLazy',
  enabled = function()
    return require('custom.env').is_personal()
  end,
  dependencies = {
    {
      'folke/snacks.nvim',
      opts = { input = {}, picker = {}, terminal = {} },
    },
  },
  init = function()
    vim.g.opencode_opts = vim.tbl_deep_extend('force', vim.g.opencode_opts or {}, {
      provider = {
        enabled = 'snacks',
      },
    })
    vim.o.autoread = true
  end,
  keys = {
    { '<leader>a', nil, desc = 'AI/OpenCode' },
    { '<leader>ac', opencode_call(function(opencode) opencode.toggle() end), desc = 'Toggle OpenCode' },
    { '<leader>ar', opencode_call(function(opencode) opencode.command 'session.select' end), desc = 'Resume/Open session' },
    { '<leader>aC', opencode_call(function(opencode) opencode.toggle() end), desc = 'Continue OpenCode' },
    { '<leader>ab', opencode_call(function(opencode) opencode.ask('@buffer: ', { submit = false }) end), desc = 'Add current buffer' },
    { '<leader>as', opencode_call(function(opencode) opencode.prompt '@this' end), mode = 'v', desc = 'Send to OpenCode' },
    {
      '<leader>as',
      opencode_call(function(opencode)
        local path = vim.api.nvim_buf_get_name(0)
        if path == '' then
          vim.notify('No file available to add', vim.log.levels.WARN)
          return
        end
        opencode.ask('@' .. path .. ': ', { submit = false })
      end),
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil' },
    },
    { '<leader>an', opencode_call(function(opencode) opencode.command 'session.new' end), desc = 'New OpenCode session' },
    { '<leader>aS', opencode_call(function(opencode) opencode.command 'session.select' end), desc = 'Session picker' },
    { '<leader>ax', opencode_call(function(opencode) opencode.stop() end), desc = 'Close OpenCode' },
  },
}
