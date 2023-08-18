local M = {}

local util = require('code-commands.util')
local conditions = require('code-commands.conditions')

local events_live = { 'BufEnter', 'TextChanged', 'InsertLeave', 'BufWritePost' }
-- local events_default = { 'BufEnter', 'BufWritePost' }

local function lint(buf, opts)
  local fname = vim.fn.fnameescape(vim.api.nvim_buf_get_name(buf))
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  coroutine.resume(coroutine.create(function()
    local ok, err = pcall(function()
      local cwd = util.get_root()

      local linters = conditions.resolve(opts.linters, conditions.CreateAPI({ buffer = buf }))

      for _, linter in ipairs(linters) do
        linter.namespace = linter.namespace
          or vim.api.nvim_create_namespace(('jg.code-commands.lint.%s'):format(linter.name))

        local results = util.run_command(linter, {
          lines = lines,
          cwd = cwd,
          filename = fname,
        }) or {}

        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.diagnostic.reset(linter.namespace, buf)
            vim.diagnostic.set(
              linter.namespace,
              buf,
              vim.tbl_map(function(e)
                return vim.tbl_extend('force', e, {
                  bufnr = buf,
                  source = linter.name,
                })
              end, results)
            )
          end
        end)
      end
    end)
    if not ok then
      print('[error]', err)
    end
  end))
end

function M.register(ft, opts)
  local events = events_live
  -- FIXME run none stdin linter only on write
  -- local events = opts.stdin and events_live or events_default

  local group = vim.api.nvim_create_augroup(('jg.code-commands.lint.%s'):format(ft), {
    clear = true,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = ft,
    callback = function(args)
      local callback = util.debounce(lint)

      vim.api.nvim_create_autocmd(events, {
        group = group,
        buffer = args.buf,
        callback = function()
          callback(args.buf, opts)
        end,
        desc = 'code-commands: Run linters',
      })
    end,
    desc = 'code-commands: Register linters',
  })
end

return M
