-- https://github.com/stevearc/conform.nvim
require("conform").setup({
  formatters_by_ft = {
    go = { "gofmt" },
    javascript = { { "prettierd", "prettier" } },
    json = { { "prettierd", "prettier" } },
    lua = { "stylua" },
    markdown = { { "prettierd", "prettier" }, "injected" },
    nix = { "nixfmt" },
    rust = { "rustfmt" },
    terraform = { "terraform_fmt" },
    yaml = { { "prettierd", "prettier" } },

    -- all filetypes
    ["*"] = { "codespell", "trim_whitespace" },

    -- unspecified filetypes
    ["_"] = { "trim_whitespace" },
  },
  format_on_save = {
    lsp_fallback = true,
  },
})
