local M = {
  name = 'shellcheck',
  cmd = 'shellcheck',
  args = { '--format', 'json1', '--source-path=$DIRNAME', '--external-sources', '-' },
  stdin = true,
  output_fmt = function(result)
    local data = vim.json.decode(result)
    local messages = data.comments or {}
    local severities = {
      error = vim.diagnostic.severity.ERROR,
      warning = vim.diagnostic.severity.WARN,
      info = vim.diagnostic.severity.INFO,
      hint = vim.diagnostic.severity.HINT,
    }

    return vim.tbl_map(function(e)
      return {
        lnum = e.line - 1,
        end_lnum = e.endLine - 1,
        col = e.column - 1,
        end_col = e.endColumn - 1,
        message = e.message,
        code = e.code,
        severity = severities[e.level],
      }
    end, messages)
  end,
}

return M

