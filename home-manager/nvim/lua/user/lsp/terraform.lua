require("lspconfig").terraformls.setup({
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
})
