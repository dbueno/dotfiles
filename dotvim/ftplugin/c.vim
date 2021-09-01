set aw
set cino+=l1,(0
set sw=2
setlocal foldmethod=indent
setlocal foldnestmax=4
setlocal foldminlines=4
setlocal fdc=4
" Fewer folds in header files
if expand("%:t") =~ ".\\(h\\|hh\\|hpp\\)"
    setlocal fdl=4
else
    setlocal fdl=1
endif
" set cursorline

" Insert comment separator
nnoremap <buffer> <Leader>is o//^----------------------------------------------------------------------------^<CR>
nnoremap <silent> <buffer> <F9> :TagbarToggle<CR>
nnoremap <silent> <buffer> <F5> :make<CR>
