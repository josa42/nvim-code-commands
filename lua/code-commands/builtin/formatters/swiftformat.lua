local M = {
  name = 'swiftformat',
  cmd = 'swiftformat',
  args = {
    '--quiet',
    '--stdinpath',
    '$FILENAME',
  },
  stdin = true,
}

return M

