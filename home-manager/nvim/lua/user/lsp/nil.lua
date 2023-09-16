require 'lspconfig'.nil_ls.setup {
    -- Server-specific settings. See `:help lspconfig-setup`
    settings = {
        ['nil'] = {
            formatting = {
                command = { "nixfmt" },
            },
        },
    },
}
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = { "*.nix" },
    callback = function()
        vim.lsp.buf.format({ async = false })
    end
})
