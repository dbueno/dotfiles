setlocal fdm=indent
" Default unfolded
setlocal fdl=8

nnoremap <buffer> <Leader>is o# -----------------------------------------------------------------------------<CR>
nnoremap <buffer> gF :Black<CR>

command! Black if &modified | echoerr "Buffer is not saved! Please save before formatting." | else | execute '!black %' | edit! | endif

augroup pyBlack
  autocmd!
  autocmd BufWritePost *.py execute ':Black'
augroup END
