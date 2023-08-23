local buf = require('code-commands.buf')

vim.api.nvim_create_user_command('CodeCommandsToggle', function()
  buf.set_var(0, 'format:disabled', not buf.get_var(0, 'format:disabled', false))
end, {})
