-- Statusline debugging utility
local M = {}

-- Function to check for problematic characters in the statusline
function M.check_statusline()
  local statusline = vim.o.statusline
  
  -- Check for angle brackets
  if statusline:match("[<>]") then
    vim.notify("Statusline contains angle brackets: " .. statusline, vim.log.levels.ERROR)
  end
  
  -- Check for control characters
  if statusline:match("[%c]") then
    vim.notify("Statusline contains control characters", vim.log.levels.ERROR)
  end
  
  -- Check for non-printable ASCII
  if statusline:match("[^\32-\126]") then
    vim.notify("Statusline contains non-printable ASCII", vim.log.levels.ERROR)
  end
  
  vim.notify("Statusline check complete", vim.log.levels.INFO)
end

-- Set up a command to run the check
vim.api.nvim_create_user_command("CheckStatusline", function()
  M.check_statusline()
end, {})

return M