local M = {}

local fs = require('code-commands.fs')
local cached = require('code-commands.cache').cached

function M.CreateAPI(ctx)
  local buf_name = vim.api.nvim_buf_get_name(ctx.buffer)
  local buf_dir = vim.fs.dirname(buf_name)

  local function node_bin_dir()
    -- TODO npm bin has been removed in npm 9
    local out = vim.trim(vim.fn.system('cd ' .. vim.fn.shellescape(buf_dir) .. '; npm bin'))

    if fs.exists(out) then
      return out
    end

    return nil
  end

  local pkg_root = fs.not_home(fs.root_pattern('package.json'))

  local find_bin_using_npm_query = cached('find_bin_using_npm_query', function(dir, name)
    local ok, res = pcall(function()
      local cmd = ('cd %s; npm query \\#%s'):format(vim.fn.shellescape(dir), name)
      local out = vim.fn.system(cmd)
      local result = vim.json.decode(out)
      if result and result[1] ~= nil then
        return fs.join(result[1].path, result[1].bin[name])
      end
    end)

    if ok then
      return res
    end

    return nil
  end)

  return {
    buffer = ctx.buffer,

    find_up = function(...)
      return vim.fs.find({ ... }, { upward = true, path = buf_dir })[1]
    end,

    find_node_package = function(name)
      return vim.fs.dirname(
        vim.fs.find(fs.join('node_modules', name, 'package.json'), { upward = true, path = buf_dir })[1]
      )
    end,

    find_node_bin = function(name)
      local checkers = {
        function()
          return fs.join(node_bin_dir(), name)
        end,
        function()
          return find_bin_using_npm_query(pkg_root(buf_name), name)
        end,
        function()
          return vim.fs.find(
            { fs.join('node_modules', '.bin', name) },
            { upward = true, path = vim.fs.dirname(buf_name) }
          )[1]
        end,
      }

      for _, fn in ipairs(checkers) do
        local bin = fn()
        if bin ~= nil and fs.exists(bin) then
          return bin
        end
      end

      return nil
    end,
  }
end

return M
