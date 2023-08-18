local M = {
  name = 'eslint_d',
  cmd = 'eslint_d',
  args = { '--fix-to-stdout', '--stdin', '--stdin-filename', '$FILENAME' },
  stdin = true,
}

return M

