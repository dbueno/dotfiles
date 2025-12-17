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

vim.lsp.config['rust-analyzer_ls'] = {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { '.git' },
  settings = {
    installCargo = false,
    installRustc = false,
    -- check = {
    --   command = "clippy",
    --   extraArgs = { "--", "-W", "clippy::pedantic", "-W", "clippy::style",
    --     "-A", "clippy::inline-always" },
    -- },
    cargo = {
      allFeatures = true,
    },
    procMacro = {
      enable = true,
    },
    completion = {
      postfix = {
        enable = false,
      },
    },
  },
}
vim.lsp.enable('rust-analyzer_ls')

vim.lsp.config['pyright_ls'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { '.git' },
  settings = {
    -- lsp settings go here
    python = {
      analysis = {
        typeCheckingMode = "standard",
      },
    },
  },
}
vim.lsp.enable('pyright_ls')



if vim.fn.executable('jdt-language-server') ~= 0 then
  jdtls_cmd = 'jdt-language-server'
elseif vim.fn.executable('jdtls') ~= 0 then
  jdtls_cmd = 'jdtls'
end

local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'build.gradle'}, { upward = true })[1])
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:h:t') .. '_' .. vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.expandcmd('~/.eclipse-workspace/') .. project_name

vim.lsp.config['jdtls_ls'] = {
  cmd = { jdtls_cmd, '-data', workspace_dir },
  filetypes = { 'java' },
  root_markers = { '.git', 'build.gradle' },
  root_dir = root_dir,
  settings = init_settings,
  init_options = {
    bundles = {},
    settings = {
      java = {
        import = {
          gradle = {
            java = {
              home = os.getenv("JDTLS_GRADLE_JAVA_HOME"),
            }
          },
        },
        configuration = {
          runtimes = {
            {
              name = "JavaSE-1.8",
              path = os.getenv("JAVA8_HOME"),
            },
            {
              name = "JavaSE-11",
              path = os.getenv("JAVA11_HOME"),
            },
            {
              name = "JavaSE-17",
              path = os.getenv("JAVA17_HOME"),
            },
          },
        },
        format = {
          comments = { enabled = false },
          enabled = true,
          settings = {
            url = os.getenv("ECLIPSE_FORMATTER_URL"),
          },
        },
        completion = {
          importOrder = {
            "java",
            "javax",
            "org",
            "com",
            "",
            "jadx",
            "\\#",
          },
        },
      },
    },
  },
}
vim.lsp.enable('jdtls_ls')

-- Normal bindings:
-- gri: implementation
-- grn: rename
-- grr: references
-- grt: type_definition
-- gO: document_symbol
-- CTRL-S: insert mode, signature help
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup("LspFormatting", {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    -- Enable completion triggered by <c-x><c-o>
    --vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'grd', vim.lsp.buf.definition, opts)
    --vim.keymap.set('n', 'gx', vim.lsp.buf.references, opts)
    --vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    --vim.keymap.set('n', 'grO', require'jdtls'.organize_imports, opts)

    -- auto format on save
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup('LspFormatting', {clear=false}),
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000, async = false })
        end,
      })
    end
  end,
})


-- show diagnostics based on current cursor line
vim.diagnostic.config({
  virtual_text = { current_line = true }
})
