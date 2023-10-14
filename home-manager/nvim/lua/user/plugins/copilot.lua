-- https://github.com/zbirenbaum/copilot.lua
-- https://github.com/fredrikaverpil/dotfiles/blob/965497f35bab9d4e3d7ef9b99fc2e1c39b7d6de7/nvim-lazyvim/lua/plugins/ai.lua
require("copilot").setup({
    copilot_node_command = vim.g.copilot_node_command,
    panel = {
        enabled = true,
        auto_refresh = true,
    },
    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = "<Tab>",
        },
    },
})

-- hide copilot suggestions when cmp menu is open
-- to prevent odd behavior/garbled up suggestions
local cmp_status_ok, cmp = pcall(require, "cmp")
if cmp_status_ok then
    cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
    end)
end
