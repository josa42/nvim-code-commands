# Nvim Code Commands

## Usage

```lua
local cmds = require('code-commands')

cmds.register({
  filetypes = { 'lua' },
  formatters = { cmds.formatters.stylua },
})

cmds.register({
  filetypes = { 'javascript', 'javascriptreact' },
  formatters = { cmds.formatters.eslint, cmds.formatters.prettier },
  linters = { cmds.linters.eslint },
})
```

<br>

### LSP formatter

Format using any attached language server.

```lua
cmds.register({
  filetypes = { 'go' },
  formatters = {
    cmds.formatters.lsp,
  },
})
```

<br>

Format using a specific attached language server.

```lua
cmds.register({
  filetypes = { 'go' },
  formatters = {
    cmds.formatters.lsp.with('gopls'),
  },
})
```

<br><br>

## Credit

- [guard.nvim](https://github.com/nvimdev/guard.nvim)

## License

[MIT © Josa Gesell](LICENSE)
