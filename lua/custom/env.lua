local M = {}

-- Create an enum-like structure for environments
M.ENV_TYPE = {
  PERSONAL = "personal",
  WORK = "work",
}

-- Detect environment (work vs personal)
function M.setup()
  -- Read the environment variable, default to "personal" if not set
  M.env = vim.env.NVIM_ENV or M.ENV_TYPE.PERSONAL

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