local M = {
  name = 'typos',
  cmd = 'typos',
  args = { '--format', 'json', '-' },
  stdin = true,
  output_fmt = function(lines)
    local diagnostics = {}
    for _, line in ipairs(vim.fn.split(lines, '\n')) do
      local data = vim.json.decode(line)

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
}

return M

