return {
  'yetone/avante.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = { file_types = { 'markdown', 'Avante' } },
      ft = { 'markdown', 'Avante' },
    },
  },
  build = 'make',
  opts = {
    provider = 'bedrock',
    bedrock = {
      model = 'arn:aws:bedrock:us-east-1:245200388354:application-inference-profile/ueecz0kt0d5i', -- Claude 3.7 Sonnet
      region = 'us-east-1',
      profile = 'default', -- Replace with your AWS CLI profile name if different
      -- Optional: Add other settings like temperature, max_tokens, etc.
    },
    vendors = {
      bedrock = {
        models = {
          sonnet_3_7 = 'arn:aws:bedrock:us-east-1:245200388354:application-inference-profile/ueecz0kt0d5i',
          sonnet_4 = 'arn:aws:bedrock:us-east-1:245200388354:application-inference-profile/0lkwwntx0xtf',
          opus_4 = 'arn:aws:bedrock:us-east-1:245200388354:application-inference-profile/rwypp3jz1073',
          -- Add other models as needed
        },
        region = 'us-east-1',
        profile = 'default',
      },
    },
  },
}
