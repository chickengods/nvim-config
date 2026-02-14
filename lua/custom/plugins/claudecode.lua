return {
  'snirt/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  event = 'VeryLazy',
  enabled = function()
    return require('custom.env').is_work()
  end,

  opts = {
    terminal_cmd = 'CLAUDE_REBUILD=true megabin claude --dangerously-skip-permissions',
    terminal = {
      provider = 'snacks', -- 'snacks' | 'native' | 'auto'
    },
  },
  keys = {
    { '<leader>a', nil, desc = 'AI/Claude Code' },
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send to Claude' },
    {
      '<leader>as',
      '<cmd>ClaudeCodeTreeAdd<cr>',
      desc = 'Add file',
      ft = { 'NvimTree', 'neo-tree', 'oil' },
    },
    -- Multi-session management
    { '<leader>an', '<cmd>ClaudeCodeNew<cr>', desc = 'New Claude session' },
    { '<leader>aS', '<cmd>ClaudeCodeSessions<cr>', desc = 'Session picker' },
    { '<leader>ax', '<cmd>ClaudeCodeCloseSession<cr>', desc = 'Close session' },
    -- Session switching (1-9) - hidden from which-key
    { '<leader>a1', '<cmd>ClaudeCodeSwitch 1<cr>', desc = 'which_key_ignore' },
    { '<leader>a2', '<cmd>ClaudeCodeSwitch 2<cr>', desc = 'which_key_ignore' },
    { '<leader>a3', '<cmd>ClaudeCodeSwitch 3<cr>', desc = 'which_key_ignore' },
    { '<leader>a4', '<cmd>ClaudeCodeSwitch 4<cr>', desc = 'which_key_ignore' },
    { '<leader>a5', '<cmd>ClaudeCodeSwitch 5<cr>', desc = 'which_key_ignore' },
    { '<leader>a6', '<cmd>ClaudeCodeSwitch 6<cr>', desc = 'which_key_ignore' },
    { '<leader>a7', '<cmd>ClaudeCodeSwitch 7<cr>', desc = 'which_key_ignore' },
    { '<leader>a8', '<cmd>ClaudeCodeSwitch 8<cr>', desc = 'which_key_ignore' },
    { '<leader>a9', '<cmd>ClaudeCodeSwitch 9<cr>', desc = 'which_key_ignore' },
  },
}
