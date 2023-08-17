local M = {}

local lint = require('code-commands.lint')
local format = require('code-commands.format')

M.formatters = require('code-commands.builtin').formatters
M.linters = require('code-commands.builtin').linters

function M.register(opts)
  vim.validate({ opts = { opts, 'table' } })

  for _, ft in ipairs(opts.filetypes) do
    lint.register(ft, opts)
    format.register(ft, opts)

    --   if opts.linters and #opts.linters > 0 then
    --     for _, linter in ipairs(opts.linters) do
    --       vim.validate({
    --         name = { linter.name, 'string' },
    --         cmd = { linter.cmd, 'string' },
    --         output_fmt = { linter.output_fmt, 'function' },
    --       })
    --     end
    --
    --     lint.register(ft, opts)
    --   end
    --
    --   if opts.formatters and #opts.formatters > 0 then
    --     for _, formatter in ipairs(opts.formatters) do
    --       vim.validate({
    --         name = { formatter.name, 'string' },
    --         cmd = { formatter.cmd, 'string' },
    --       })
    --     end
    --
    --     format.register(ft, opts)
    --   end
  end
end

return M
