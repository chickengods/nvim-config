local M = {}

-- Create an enum-like structure for environments
M.ENV_TYPE = {
  PERSONAL = "personal",
  WORK = "work",
}

local function read_nvim_env_file()
  local env_file = vim.fn.stdpath('config') .. '/.nvim-env'
  local file = io.open(env_file, 'r')
  if not file then
    return nil
  end

  local value = nil
  for line in file:lines() do
    local trimmed = vim.trim(line)
    if trimmed ~= '' and not trimmed:match '^#' then
      local key, parsed = trimmed:match '^([%w_]+)%s*=%s*(.+)$'
      if key == 'NVIM_ENV' and parsed and parsed ~= '' then
        value = parsed
        break
      elseif not key then
        value = trimmed
        break
      end
    end
  end

  file:close()
  return value
end

-- Detect environment (work vs personal)
function M.setup()
  -- Read environment selector in this order:
  -- 1. Process environment variable (easy one-off override)
  -- 2. Local config file in this repo (machine-specific default)
  -- 3. Personal fallback
  M.env = vim.env.NVIM_ENV or read_nvim_env_file() or M.ENV_TYPE.PERSONAL

  -- Validate that the environment is one of the allowed types
  local valid_env = false
  for _, env_value in pairs(M.ENV_TYPE) do
    if M.env == env_value then
      valid_env = true
      break
    end
  end

  -- If invalid, fall back to personal
  if not valid_env then
    vim.notify("Invalid NVIM_ENV value: " .. M.env .. ". Using personal environment.", vim.log.levels.WARN)
    M.env = M.ENV_TYPE.PERSONAL
  end

  -- Make this available to the rest of the config
  vim.g.nvim_env = M.env

  -- Log which environment is active
  vim.notify("Neovim environment: " .. M.env, vim.log.levels.INFO)
end

-- Check if current environment is the specified one
function M.is(env_name)
  return M.env == env_name
end

-- Check if current environment is work
function M.is_work()
  return M.env == M.ENV_TYPE.WORK
end

-- Check if current environment is personal
function M.is_personal()
  return M.env == M.ENV_TYPE.PERSONAL
end

return M
