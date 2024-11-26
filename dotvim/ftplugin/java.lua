vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gF', vim.lsp.buf.format, opts)
  end,
})

local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'build.gradle'}, { upward = true })[1])
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:h:t') .. '_' .. vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.expandcmd('~/.eclipse-workspace/') .. project_name
local init_settings = {
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
  }

if vim.fn.executable('jdt-language-server') ~= 0 then
  jdtls_cmd = 'jdt-language-server'
elseif vim.fn.executable('jdtls') ~= 0 then
  jdtls_cmd = 'jdtls'
end

local config = {
  name = 'jdtls-server',
  cmd = {jdtls_cmd, '-data', workspace_dir},
  root_dir = root_dir,
  -- This is currently required to have the server read the settings,
  -- In a future neovim build this may no longer be required
  -- on_init = function(client)
  --   client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  -- end
  settings = init_settings,
  init_options = {
    bundles = {},
    settings = init_settings,
  },
}


-- Decides which lsp to run
local custom_lsp_cmd = os.getenv("CUSTOM_LSP_COMMAND")

if custom_lsp_cmd ~= nil then
  -- Test my lsp
  vim.lsp.start({
    name = 'custom_lsp',
    cmd = {custom_lsp_cmd},
    root_dir = vim.fs.find({'sources'}, { upward = true })[1],
  })
elseif jdtls_cmd ~= nil then
  require('jdtls').start_or_attach(config)
end
