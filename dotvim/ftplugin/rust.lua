local lspconfig = require'lspconfig'
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
lspconfig.rust_analyzer.setup {
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format()
        end,
      })
    end
  end,
  flags = {
    debounce_text_changes = 150,
    },
  settings = {
    ["rust-analyzer"] = {
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
  },
  capabilities = capabilities,
}
