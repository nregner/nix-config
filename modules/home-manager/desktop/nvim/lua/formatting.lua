-- [nfnl] Compiled from fnl/formatting.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_(_, opts)
  require("conform").setup(opts)
  local function _2_(args)
    if args.bang then
      vim.g.disable_autoformat = true
      return nil
    else
      vim.b.disable_autoformat = true
      return nil
    end
  end
  vim.api.nvim_create_user_command("FormatDisable", _2_, {bang = true, desc = "Disable autoformat-on-save"})
  local function _4_(args)
    if args.bang then
      vim.g.disable_autoformat = false
    else
    end
    vim.b.disable_autoformat = false
    return nil
  end
  return vim.api.nvim_create_user_command("FormatEnable", _4_, {desc = "Re-enable autoformat-on-save"})
end
local function _6_(bufnr)
  if not (vim.g.disable_autoformat or vim.b.bufnr.disable_autoformat) then
    return {lsp_format = "fallback", timeout_ms = 500}
  else
    return nil
  end
end
return {"stevearc/conform.nvim", config = _1_, opts = {format_on_save = _6_, formatters = {nginxfmt = {args = {"--pipe"}, command = "nginxfmt"}, prettier = {options = {ft_parsers = {gitcommit = "markdown"}}}}, formatters_by_ft = {["*"] = {"trim_whitespace"}, _ = {"trim_whitespace"}, bash = {"shfmt"}, clojure = {"joker"}, css = {"prettierd"}, gitcommit = {"prettier", "injected"}, go = {"gofmt"}, graphql = {"prettierd"}, html = {"prettierd"}, javascript = {"prettierd"}, javascriptreact = {"prettierd"}, json = {"prettierd"}, jsonc = {"prettierd"}, lua = {"stylua"}, markdown = {"prettierd", "injected"}, nginx = {"nginxfmt"}, nix = {"nixfmt", "injected"}, rust = {"rustfmt"}, sh = {"shfmt"}, terraform = {"terraform_fmt"}, typescript = {"prettierd"}, typescriptreact = {"prettierd"}, vue = {"prettierd"}, yaml = {"prettierd"}}}}
