-- https://github.com/nvim-tree/nvim-tree.lua

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local view_width_max = 30

return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    {
      "<leader>ft",
      function()
        require("nvim-tree.api").tree.open({ find_file = true })
      end,
      desc = "[F]ind file in [T]ree",
    },
  },
  opts = {
    update_cwd = true,
    hijack_cursor = true,
    view = {
      width = {
        max = function()
          return view_width_max
        end,
      },
    },
    on_attach = function(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
        }
      end

      api.config.mappings.default_on_attach(bufnr)

      vim.keymap.set("n", "A", function()
        print("view_width_max", view_width_max)
        if view_width_max == -1 then
          view_width_max = 30
        else
          view_width_max = -1
        end
        api.tree.reload()
      end, opts("Toggle Adaptive Width"))
    end,
  },
}
