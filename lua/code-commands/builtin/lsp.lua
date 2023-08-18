local l = {}

local M = {}

function M.create(name)
  return function(ctx)
    local client = l.select_client('textDocument/formatting', name)
    if client ~= nil then
      return {
        name = ('lsp-format:%s'):format(name),
        fn = function()
          l.buf_formatting(client, ctx.buffer)
        end,
      }
    end
  end
end

function l.buf_formatting(client, bufnr)
  local encoding = vim.api.nvim_buf_get_option(bufnr, 'fileencoding')

  l.request_organize_imports(client, bufnr, encoding)
  l.request_formatting(client, bufnr, encoding)
end

function l.request_formatting(client, bufnr, encoding)
  local params = vim.lsp.util.make_formatting_params(nil)

  l.request(client, 'textDocument/formatting', params, bufnr, function(result)
    vim.lsp.util.apply_text_edits(result, bufnr, encoding)
  end)
end

function l.request_organize_imports(client, bufnr, encoding)
  if client.name == 'gopls' then
    l.gopls_organize_imports(client, bufnr, encoding)
  elseif client.name == 'tsserver' then
    l.tsserver_organize_imports(client, bufnr)
  end
end

-- organize imports for gopls
function l.gopls_organize_imports(client, bufnr, encoding)
  local params = vim.tbl_extend('force', vim.lsp.util.make_range_params(), {
    source = { organizeImports = true },
  })

  l.request(client, 'textDocument/codeAction', params, bufnr, function(result)
    for _, r in ipairs(result) do
      vim.lsp.util.apply_workspace_edit(r.edit, encoding)
    end
  end)
end

-- organize imports for tsserver
function l.tsserver_organize_imports(client, bufnr)
  local params = {
    command = '_typescript.organizeImports',
    arguments = { vim.api.nvim_buf_get_name(bufnr) },
  }

  l.request(client, 'workspace/executeCommand', params, bufnr)
end

function l.request(client, method, params, bufnr, apply_fn)
  local response = client.request_sync(method, params, 1000, bufnr)
  if apply_fn ~= nil and response ~= nil and response.result ~= nil then
    apply_fn(response.result)
  end
end

function l.select_client(method, client_name)
  local clients = vim.tbl_filter(function(client)
    return client.supports_method(method)
  end, vim.tbl_values(vim.lsp.get_clients()))

  table.sort(clients, function(a, b)
    return a.name < b.name
  end)

  local client = vim.tbl_filter(function(client)
    return client.name == client_name
  end, clients)[1]

  if client ~= nil then
    return client
  end

  return nil
end

return M
