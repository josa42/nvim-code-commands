local M = {
  name = 'prettier',
  cmd = 'prettier',
  args = { '--stdin-filepath', '$FILENAME' },
  stdin = true,
}

return M

