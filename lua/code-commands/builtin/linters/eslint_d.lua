local M = {
  name = 'eslint_d',
  cmd = 'eslint_d',
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

