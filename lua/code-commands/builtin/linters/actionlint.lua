local M = {
  name = 'actionlint',
  cmd = 'actionlint',
  stdin = true,
  args = function(opts)
    local args = { '-no-color', '-format', '{{json .}}' }

    -- actionlint ignores config files when reading from stdin
    -- unless they are explicitly passed.

    local config_file_path = vim.fs.find({
      '.github/actionlint.yml',
      '.github/actionlint.yaml',
    }, {
      path = opts.filename,
      upward = true,
      stop = vim.fs.dirname(opts.root),
    })[1]

    if config_file_path then
      args = vim.list_extend(args, { '-config-file', config_file_path })
    end

    return vim.list_extend(args, { '-' })
  end,
  output_fmt = function(result)
    local messages = vim.json.decode(result)

    return vim.tbl_map(function(e)
      return {
        lnum = e.line - 1,
        col = e.column - 1,
        end_col = e.end_column - 1,
        message = e.message,
        severity = vim.diagnostic.severity.ERROR,
      }
    end, messages)
  end,
}

return M

