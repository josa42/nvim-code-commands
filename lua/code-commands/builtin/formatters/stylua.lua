local M = {
  name = 'stylua',
  cmd = 'stylua',
  args = { '--search-parent-directories', '--stdin-filepath', '$FILENAME', '-' },
  stdin = true,
}

return M

