local fs = require('code-commands.fs')

local M = {
  name = 'eslint',
  cmd = function(ctx)
    local local_eslint = vim.fs.joinpath(ctx.root, 'node_modules/.bin/eslint')
    if fs.exists(local_eslint) then
      return local_eslint
    end
    return 'eslint'
  end,
  args = { '-f', 'json', '--stdin', '--stdin-filename', '$FILENAME' },
  stdin = true,
  output_fmt = function(result)
    local data = vim.json.decode(result)
    local messages = data[1] and data[1].messages or {}

    return vim.tbl_map(function(e)
      return {
        col = e.column,
        lnum = e.line - 1,
        message = e.message,
        severity = e.severity,
        code = e.ruleId,
      }
    end, messages)
  end,
}

return M

