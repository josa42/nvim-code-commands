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
  args = { '--fix-dry-run', '--format', 'json', '--stdin', '--stdin-filename', '$FILENAME' },
  stdin = true,
  success_exit_codes = { 0, 1 },
  output_fmt = function(result)
    local data = vim.json.decode(result)
    return data[1] and data[1].output or nil
  end,
}

return M

