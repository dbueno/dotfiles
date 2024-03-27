require'nvim-treesitter.configs'.setup {
highlight = {
  enable = true,              -- false will disable the whole extension
  disable = { },  -- list of language that will be disabled
  -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
  -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
  -- Using this option may slow down your editor, and you may see some duplicate highlights.
  -- Instead of true it can also be a list of languages
  additional_vim_regex_highlighting = false,
},
}

require'lspconfig'.pyright.setup{}
require'lspconfig'.ocamllsp.setup{}

-- Binds K to buf.hover. This should happen by default but doesn't happen, so
-- force it.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf })
  end,
})
