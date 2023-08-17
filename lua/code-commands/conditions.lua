local function append(tbl1, tbl2)
  for _, entry in ipairs(tbl2) do
    table.insert(tbl1, entry)
  end
  return tbl1
end

local M = {}

function M.all(commands)
  return commands
end

function M.one(commands)
  return function(api)
    for _, cmd in ipairs(commands) do
      if type(cmd) == 'function' then
        local c = cmd(api)
        if c ~= nil then
          return M.resolve(c, api)
        end
      else
        return M.resolve(cmd, api)
      end
    end

    return {}
  end
end

function M.condition(command, condition)
  return function(api)
    local t = type(condition)

    if t == 'function' then
      if condition(api) then
        return command
      end
    else
      return command and true or false
    end
  end
end

function M.resolve(commands, api)
  local ok, ret = pcall(function()
    assert(api ~= nil)

    local resolved = {}

    if type(commands) == 'function' then
      resolved = append(resolved, M.resolve(commands(api), api))
    elseif vim.tbl_islist(commands) then
      for _, cmd in ipairs(commands) do
        resolved = append(resolved, M.resolve(cmd, api))
      end
    elseif commands ~= nil then
      table.insert(resolved, commands)
    end

    return resolved
  end)

  if not ok then
    print('[error]', ret)
    return {}
  end

  return ret
end

function M.find_up(...)
  local files = { ... }
  return function(api)
    return api.find_up(unpack(files)) ~= nil
  end
end

function M.find_node_package(name)
  return function(api)
    return api.find_node_package(name) ~= nil
  end
end

function M.find_node_bin(name)
  return function(api)
    return api.find_node_bin(name) ~= nil
  end
end

function M.if_not(fn)
  return function(api)
    return not fn(api)
  end
end

function M.if_all(...)
  local fns = { ... }
  return function(api)
    for fn in ipairs(fns) do
      if not fn(api) then
        return false
      end
    end

    return true
  end
end

function M.if_any(...)
  local fns = { ... }
  return function(api)
    for fn in ipairs(fns) do
      if fn(api) then
        return true
      end
    end

    return false
  end
end

M.CreateAPI = require('code-commands.conditions-api').CreateAPI

return M
