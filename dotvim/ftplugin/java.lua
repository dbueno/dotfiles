local root_dir = vim.fs.dirname(vim.fs.find({'.git', 'build.gradle'}, { upward = true })[1])
local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
local workspace_dir = vim.fn.expandcmd('~/.eclipse-workspace/') .. project_name
local jdk_settings = {
    java = {
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
    },
  }
local config = {
  name = 'jdtls-server',
  cmd = {'jdt-language-server', '-data', workspace_dir},
  root_dir = root_dir,
  -- This is currently required to have the server read the settings,
  -- In a future neovim build this may no longer be required
  -- on_init = function(client)
  --   client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  -- end
  settings = jdk_settings,
  init_options = {
    bundles = {},
    settings = jdk_settings,
  },
}
require('jdtls').start_or_attach(config)
