local M = {}

local util = require('code-commands.util')
local conditions = require('code-commands.conditions')

local function format(buf, opts)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local fname = vim.fn.fnameescape(vim.api.nvim_buf_get_name(buf))

  local changedtick = vim.api.nvim_buf_get_changedtick(buf)

  local cwd = util.get_root()

  local formatters = conditions.resolve(
    opts.formatters,
    conditions.CreateAPI({
      buffer = buf,
    })
  )

  for _, formatter in ipairs(formatters) do
    local success, err = pcall(function()
      local out, success = util.run_command(formatter, {
        lines = lines,
        cwd = cwd,
        filename = fname,
      })

      if success and out ~= nil and out ~= '' then
        lines = vim.split(out, '\n')
      end
    end)

    if not success then
      print('[error]', err)
    end
  end

  if changedtick == vim.api.nvim_buf_get_changedtick(buf) then
    util.update_buffer(buf, lines, 0, -1)
  end
end

function M.register(ft, opts)
  local group = vim.api.nvim_create_augroup(('jg.code-commands.format.%s'):format(ft), {
    clear = true,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = ft,
    callback = function(args)
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = group,
        buffer = args.buf,
        callback = function()
          format(args.buf, opts)
        end,
        desc = 'code-commands: Run formatters',
      })
    end,
    desc = 'code-commands: Register formatters',
  })
end

return M
