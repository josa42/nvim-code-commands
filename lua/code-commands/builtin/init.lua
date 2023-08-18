local M = {}

M.formatters = {
  eslint = require('code-commands.builtin.formatters.eslint'),
  eslint_d = require('code-commands.builtin.formatters.eslint_d'),
  prettier = require('code-commands.builtin.formatters.prettier'),
  stylua = require('code-commands.builtin.formatters.stylua'),
  shfmt = require('code-commands.builtin.formatters.shfmt'),
  swiftformat = require('code-commands.builtin.formatters.swiftformat'),
  fixjson = require('code-commands.builtin.formatters.fixjson'),
  lsp = require('code-commands.builtin.formatters.lsp'),
}

M.linters = {
  eslint = require('code-commands.builtin.linters.eslint'),
  eslint_d = require('code-commands.builtin.linters.eslint_d'),
  shellcheck = require('code-commands.builtin.linters.shellcheck'),
  actionlint = require('code-commands.builtin.linters.actionlint'),
  typos = require('code-commands.builtin.linters.typos'),
}

return M
