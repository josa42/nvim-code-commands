local M = {
  name = 'eslint',
  cmd = 'eslint',
  args = { '--fix-dry-run', '--format', 'json', '--stdin', '--stdin-filename', '$FILENAME' },
  stdin = true,
  output_fmt = function(result)
    local data = vim.json.decode(result)
    return data[1] and data[1].output or nil
  end,
}

return M

