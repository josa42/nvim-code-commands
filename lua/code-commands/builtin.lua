local M = {}

M.formatters = {
  eslint = {
    name = 'eslint',
    cmd = 'eslint',
    args = { '--fix-dry-run', '--format', 'json', '--stdin', '--stdin-filename', '$FILENAME' },
    stdin = true,
    output_fmt = function(result)
      local data = vim.json.decode(result)
      return data[1] and data[1].output or nil
    end,
  },

  eslint_d = {
    name = 'eslint_d',
    cmd = 'eslint_d',
    args = { '--fix-to-stdout', '--stdin', '--stdin-filename', '$FILENAME' },
    stdin = true,
  },

  prettier = {
    name = 'prettier',
    cmd = 'prettier',
    args = { '--stdin-filepath', '$FILENAME' },
    stdin = true,
  },

  stylua = {
    name = 'stylua',
    cmd = 'stylua',
    args = { '--search-parent-directories', '--stdin-filepath', '$FILENAME', '-' },
    stdin = true,
  },

  shfmt = {
    name = 'shfmt',
    cmd = 'shfmt',
    args = {
      '--indent=2', -- 0 for tabs (default), >0 for number of spaces
      '--binary-next-line', -- binary ops like && and | may start a line
      '--case-indent', -- switch cases will be indented
      '--space-redirects', -- redirect operators will be followed by a space
      -- '--keep-padding', -- keep column alignment paddings
      -- '--func-next-line', -- function opening braces are placed on a separate line
      '--filename=$FILENAME',
    },
    stdin = true,
  },

  swiftformat = {
    name = 'swiftformat',
    cmd = 'swiftformat',
    args = {
      '--quiet',
      '--stdinpath',
      '$FILENAME',
    },
    stdin = true,
  },

  fixjson = {
    name = 'fixjson',
    cmd = 'fixjson',
    stdin = true,
  },

  lsp = require('code-commands.builtin.lsp').create,
}

M.linters = {
  eslint = {
    name = 'eslint',
    cmd = 'eslint',
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
  },

  eslint_d = {
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
  },

  shellcheck = {
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
  },

  actionlint = {
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
  },

  typos = {
    name = 'typos',
    cmd = 'typos',
    args = { '--format', 'json', '-' },
    stdin = true,
    output_fmt = function(lines)
      local diagnostics = {}
      for _, line in ipairs(vim.fn.split(lines, '\n')) do
        local data = vim.json.decode(line)

        D({ data = data, line = line })

        local format_message = function(typo, corrections)
          local message = ('"%s" should be '):format(typo)

          for i, correction in ipairs(corrections) do
            message = ('%s"%s"'):format(message, correction)

            if i < #corrections - 1 then
              message = ('%s, '):format(message)
            elseif i == #corrections - 1 then
              message = ('%s or '):format(message)
            end
          end

          return ('%s.'):format(message)
        end

        table.insert(diagnostics, {
          message = format_message(data.typo, data.corrections),
          severity = vim.diagnostic.severity.WARN,
          lnum = data.line_num - 1,
          col = data.byte_offset,
          end_col = data.byte_offset + data.typo:len(),
        })
      end

      return diagnostics
    end,
  },
}

return M
