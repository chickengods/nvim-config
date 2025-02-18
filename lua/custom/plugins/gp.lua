return {
  'robitx/gp.nvim',
  config = function()
    local conf = {
      -- For customization, refer to Install > Configuration in the Documentation/Readme
      default_chat_agent = 'ChatGemini',
      providers = {
        -- secrets can be strings or tables with command and arguments
        -- secret = { "cat", "path_to/openai_api_key" },
        -- secret = { "bw", "get", "password", "OPENAI_API_KEY" },
        -- secret : "sk-...",
        -- secret = os.getenv("env_name.."),
        openai = {
          disable = true,
          endpoint = 'https://api.openai.com/v1/chat/completions',
          secret = os.getenv 'OPENAI_API_KEY',
        },
        googleai = {
          disable = false,
          endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={{secret}}',
          secret = os.getenv 'GOOGLEAI_API_KEY',
        },
      },
    }
    require('gp').setup(conf)

    -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
  end,
}
