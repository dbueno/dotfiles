command! NixFmt if &modified | echoerr "Buffer is not saved! Please save before formatting." | else | execute '!nix fmt --offline %' | edit! | endif
nnoremap <buffer> gF :NixFmt<CR>

" augroup nixFmt
"   autocmd!
"   autocmd BufWritePost *.py execute ':NixFmt'
" augroup END
