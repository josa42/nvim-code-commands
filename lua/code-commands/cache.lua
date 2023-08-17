local M = {}

M.cache = {}

function M.has_cache(key)
  return M.cache[key] ~= nil
end

function M.get_cache(key, default)
  if M.has_cache(key) then
    return M.cache[key].value
  end
  return default
end

function M.set_cache(key, value)
  -- print('set  --> ' .. key .. ' = ' .. vim.json.encode(value))
  M.cache[key] = { value = value }
  return value
end

function M.cached(key_base, fn)
  return function(...)
    local key = table.concat(
      vim.tbl_map(function(a)
        local t = type(a)
        if t == 'table' and a.bufname ~= nil then
          return a.bufname
        end

        return a
      end, { key_base, ... }),
      ':'
    )

    if M.has_cache(key) then
      return M.get_cache(key)
    end

    return M.set_cache(key, fn(...))
  end
end

return M
