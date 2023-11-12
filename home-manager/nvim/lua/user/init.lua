require("user.keybinds")

require("user.lsp")
require("user.lsp.gopls")
require("user.lsp.lua")
-- require("user.lsp.nil")
require("user.lsp.nixd")
require("user.lsp.rust-analyzer")
require("user.lsp.terraform")

require("user.plugins.catppuccin")
require("user.plugins.conform")
require("user.plugins.cmp")
require("user.plugins.colorizer")
require("user.plugins.copilot")
require("user.plugins.diffview")
require("user.plugins.lualine")
require("user.plugins.mini-nvim")
require("user.plugins.navigator")
require("user.plugins.nvim-tree")
require("user.plugins.telescope")

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.nu = {
  filetype = "nu",
}
