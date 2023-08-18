local M = {
  name = 'shfmt',
  cmd = 'shfmt',
  args = {
    '--indent=2', -- 0 for tabs (default), >0 for number of spaces
    '--binary-next-line', -- binary ops like && and | may start a line
    '--case-indent', -- switch cases will be indented
    '--space-redirects', -- redirect operators will be followed by a space
    -- '--keep-padding', -- keep column alignment paddings
    -- '--func-next-line', -- function opening braces are placed on a separate line
    '--filename=$FILENAME',
  },
  stdin = true,
}

return M

