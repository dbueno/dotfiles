command! NixFmt if &modified | echoerr "Buffer is not saved! Please save before formatting." | else | execute '!nix fmt %' | edit! | endif

" augroup nixFmt
"   autocmd!
"   autocmd BufWritePost *.py execute ':NixFmt'
" augroup END
