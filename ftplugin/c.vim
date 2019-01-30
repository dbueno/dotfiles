set aw
set cino+=l1,(0
set sw=2
setlocal foldmethod=syntax
"marker
setlocal foldnestmax=4
setlocal foldminlines=4
set cursorline

" Insert comment separator
nnoremap <buffer> <Leader>is o//*-------------------------------------------------------------------------------*<CR>
