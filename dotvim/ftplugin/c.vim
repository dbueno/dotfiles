set aw
set cino+=l1,(0
set sw=2
setlocal foldmethod=indent
setlocal foldnestmax=4
setlocal foldminlines=4
setlocal fdc=4
" set cursorline

" Insert comment separator
nnoremap <buffer> <Leader>is o//^----------------------------------------------------------------------------^<CR>
nnoremap <silent> <buffer> <F9> :TagbarToggle<CR>
nnoremap <silent> <buffer> <F5> :make<CR>
