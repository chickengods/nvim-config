return {
  'saghen/blink.cmp',
  version = '1.*',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'giuxtaposition/blink-cmp-copilot',
  },
  event = 'InsertEnter',
  opts = {
    -- Use default preset for familiar keymaps (C-y to accept, similar to nvim-cmp)
    keymap = { preset = 'default' },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    -- Experimental signature help
    signature = { enabled = true },

    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = true,
      },
    },

    -- Frecency and proximity-based sorting
    fuzzy = {
      frecency = {
        enabled = true,
        path = vim.fn.stdpath('state') .. '/blink/cmp/frecency.dat',
      },
      use_proximity = true, -- prioritize items closer to cursor
    },

    -- Default sources
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100, -- Prioritize lazydev completions
        },
        copilot = {
          name = 'copilot',
          module = 'blink-cmp-copilot',
          score_offset = 100,
          async = true,
          transform_items = function(_, items)
            local CompletionItemKind = require('blink.cmp.types').CompletionItemKind
            local kind_idx = #CompletionItemKind + 1
            CompletionItemKind[kind_idx] = 'Copilot'
            for _, item in ipairs(items) do
              item.kind = kind_idx
            end
            return items
          end,
        },
      },
    },
  },
  opts_extend = { 'sources.default' },
}
