local function go_test_file_toggle()
  local file = vim.fn.expand '%:p'

  if not file:match '.go' then
    print 'Not a go file'
    return
  end

  if file:match '_test.go' then
    file = file:gsub('_test.go', '.go')
  else
    file = file:gsub('.go', '_test.go')
  end

  if vim.fn.filereadable(file) == 1 then
    vim.cmd('e ' .. file)
  else
    print('Go test file not found:' .. file)
  end
end
