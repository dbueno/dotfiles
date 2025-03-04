function Black()
  local buf = vim.api.nvim_get_current_buf()
  local path = vim.api.nvim_buf_get_name(buf)
  local modified = vim.api.nvim_buf_get_option(buf, 'modified')
  vim.fn.system('black ' .. path)
  vim.cmd('edit!')
end

vim.api.nvim_create_user_command('Black', Black, {})
--vim.cmd('command! Black if &modified | echoerr "Buffer is not saved! Please save before formatting." | else | lua Black() | edit! | endif')

vim.cmd([[
  augroup pyBlack
    autocmd!
    autocmd BufWritePost <buffer> execute ':Black'
  augroup END
]])
