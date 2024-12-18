  augroup rustFmt
    autocmd!
    autocmd BufWritePost *.rs execute ':RustFmt'
  augroup END
