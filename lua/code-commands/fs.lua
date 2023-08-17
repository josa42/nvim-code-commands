local M = {}

local is_windows = vim.loop.os_uname().version:match('Windows')
local path_separator = is_windows and '\\' or '/'

function M.exists(filename)
  local stat = vim.loop.fs_stat(filename)
  return stat ~= nil
end

function M.join(...)
  return table.concat(vim.tbl_flatten({ ... }), path_separator):gsub(path_separator .. '+', path_separator)
end

--- creates a callback that returns the first root matching a specified pattern
---@vararg string patterns
---@return fun(startpath: string): string|nil root_dir
M.root_pattern = function(...)
  local patterns = vim.tbl_flatten({ ... })

  local function matcher(path)
    if not path then
      return nil
    end

    -- escape wildcard characters in the path so that it is not treated like a glob
    path = path:gsub('([%[%]%?%*])', '\\%1')
    for _, pattern in ipairs(patterns) do
      ---@diagnostic disable-next-line: param-type-mismatch
      for _, p in ipairs(vim.fn.glob(M.join(path, pattern), true, true)) do
        if M.exists(p) then
          return path
        end
      end
    end

    return nil
  end

  return function(start_path)
    local start_match = matcher(start_path)
    if start_match then
      return start_match
    end

    for path in vim.fs.parents(start_path) do
      local match = matcher(path)
      if match then
        return match
      end
    end
  end
end

function M.not_home(fn)
  local home = os.getenv('HOME')
  return function(ctx)
    local dir = fn(ctx)
    if dir == home then
      return nil
    end
    return dir
  end
end

return M
