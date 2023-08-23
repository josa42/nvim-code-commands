local M = {}

function M.get_var(buf, key, default)
  local ok, val = pcall(vim.api.nvim_buf_get_var, buf, ('code-commands:%s'):format(key))
  if ok and val ~= nil then
    return val
  end
  return default
end

function M.set_var(buf, key, value)
  vim.api.nvim_buf_set_var(buf, ('code-commands:%s'):format(key), value)
end

return M

