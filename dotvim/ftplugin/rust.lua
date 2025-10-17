local lspconfig = require'lspconfig'
lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
    },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
        extraArgs = { "--", "-W", "clippy::pedantic", "-W", "clippy::style",
          "-A", "clippy::inline-always" },
      },
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
  },
  capabilities = capabilities,
}
