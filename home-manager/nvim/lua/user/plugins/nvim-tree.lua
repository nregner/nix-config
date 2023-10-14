-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({})

local api = require('nvim-tree.api')
vim.keymap.set('n', '<leader>ft', function()
    print('find')
    api.tree.open({ find_file = true, })
end, {})
