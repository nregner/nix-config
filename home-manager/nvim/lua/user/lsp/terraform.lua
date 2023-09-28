require 'lspconfig'.terraformls.setup {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
}
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.tf", "*.tfvars" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end
})
