local M = {}

---@diagnostic disable-next-line: deprecated
local uv = vim.version().minor >= 10 and vim.uv or vim.loop

---@diagnostic disable-next-line: deprecated
local get_clients = vim.version().minor >= 10 and vim.lsp.get_clients or vim.lsp.get_active_clients

function M.get_lsp_root()
  local curbuf = vim.api.nvim_get_current_buf()
  local clients = get_clients({ bufnr = curbuf })
  if #clients == 0 then
    return
  end
  for _, client in ipairs(clients) do
    if client.config.root_dir then
      return client.config.root_dir
    end
  end
end

function M.get_root()
  return M.get_lsp_root() or uv.cwd()
end

function M.debounce(fn)
  local timer = nil

  return function(...)
    if timer then
      timer:stop()
      timer = nil
    end

    local args = { ... }

    timer = uv.new_timer()
    timer:start(500, 0, function()
      timer:stop()
      timer:close()
      timer = nil
      vim.schedule(function()
        fn(unpack(args))
      end)
    end)
  end
end

function M.update_buffer(bufnr, lines, srow, erow)
  if not vim.api.nvim_buf_is_valid(bufnr) or not lines or #lines == 0 then
    return
  end

  local view = vim.fn.winsaveview()
  local prev_lines = vim.api.nvim_buf_get_lines(bufnr, srow, erow, true)

  if lines[#lines] == 0 then
    lines[#lines] = nil
  end

  local diffs = vim.diff(table.concat(lines, '\n'), table.concat(prev_lines, '\n'), {
    algorithm = 'minimal',
    ctxlen = 0,
    result_type = 'indices',
  })

  if not diffs or #diffs == 0 then
    return
  end

  -- Apply diffs in reverse order.
  for i = #diffs, 1, -1 do
    local new_start, new_count, prev_start, prev_count = unpack(diffs[i])
    local replacement = {}
    for j = new_start, new_start + new_count - 1, 1 do
      replacement[#replacement + 1] = lines[j]
    end
    local s, e
    if prev_count == 0 then
      s = prev_start
      e = s
    else
      s = prev_start - 1 + srow
      e = s + prev_count
    end
    vim.api.nvim_buf_set_lines(bufnr, s, e, false, replacement)
  end

  vim.fn.winrestview(view)
end

function M.run_command(cmd, opts)
  local args = cmd.args or {}
  if type(cmd.args) == 'function' then
    args = cmd.args({
      root = opts.cwd,
      filename = opts.filename,
    })
  end

  local out, success = M.exec(vim.tbl_extend('force', cmd, {
    lines = cmd.stdin and opts.lines or nil,
    cwd = opts.cwd,
    args = vim.tbl_map(function(arg)
      arg = arg:gsub('$FILENAME', opts.filename)
      return arg
    end, args),
  }))

  if #out > 0 then
    if cmd.output_fmt then
      return cmd.output_fmt(out), success
    end

    return out, success
  end

  return nil, false
end

function M.exec(opt)
  opt = opt or {}

  local timeout = opt.timeout or 2000

  local results
  local status = 0
  local done = false

  local chunks = {}
  local handle

  local stdin = opt.lines and assert(uv.new_pipe()) or nil
  local stdout = assert(uv.new_pipe())
  local stderr = assert(uv.new_pipe())

  handle = uv.spawn(
    opt.cmd,
    {
      stdio = { stdin, stdout, stderr },
      args = opt.args or {},
      cwd = opt.cwd,
      env = opt.env_flat or nil,
    },
    vim.schedule_wrap(function(s)
      stdout:read_stop()
      stdout:close()
      stderr:read_stop()
      stderr:close()
      handle:close()

      results = table.concat(chunks, '')
      status = s

      done = true
    end)
  )

  local on_read = function(_, chunk)
    if chunk then
      table.insert(chunks, chunk)
    end
  end

  uv.read_start(stderr, on_read)
  uv.read_start(stdout, on_read)

  if stdin then
    stdin:write(vim.tbl_map(function(line)
      return line .. '\n'
    end, opt.lines))

    uv.shutdown(stdin)
  end

  vim.wait(timeout, function()
    return done
  end, 10)

  if not handle:is_closing() then
    handle:close()
  end

  return results, status == 0
end

return M
