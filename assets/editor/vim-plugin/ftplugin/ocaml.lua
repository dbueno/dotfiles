vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gF', vim.lsp.buf.format, opts)
  end,
})
