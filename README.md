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

## Credit

- [guard.nvim](https://github.com/nvimdev/guard.nvim)

## License

[MIT © Josa Gesell](LICENSE)
