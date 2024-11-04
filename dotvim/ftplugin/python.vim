setlocal fdm=indent
" Default unfolded
setlocal fdl=4

nnoremap <buffer> <Leader>is o# -----------------------------------------------------------------------------<CR>

command! Black if &modified | echoerr "Buffer is not saved! Please save before formatting." | else | execute '!black %' | edit! | endif

nnoremap <buffer> gF :Black<CR>
