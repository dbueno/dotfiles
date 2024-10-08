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
require'lspconfig'.rust_analyzer.setup {}

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.expandcmd('~/.eclipse-workspace/') .. project_name
local config = {
  -- <here goes your normal configuration, like the cmd etc>
  name = 'jdtls-server',
  cmd = {'jdt-language-server', '-data', workspace_dir},
  root_dir = vim.fs.dirname(vim.fs.find({'.git', 'build.gradle'}, { upward = true })[1]),
  -- This is currently required to have the server read the settings,
  -- In a future neovim build this may no longer be required
  -- on_init = function(client)
  --   client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  -- end
}

-- Set up initialization options, where we tell the java language server
-- (jdtls) here the correct JDK lives.
config.init_options = {
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-8",
            path = os.getenv("JAVA8_HOME"),
            default = true,
          },
        },
      },
    },
  },
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function(args)
    vim.lsp.start(config)
  end,
})

-- Binds K to buf.hover. This should happen by default but doesn't happen, so
-- force it.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
  end,
})
