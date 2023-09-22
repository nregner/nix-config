-- map helper
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- https://github.com/neovim/neovim/issues/23093
map('n', '<leader>ex', function()
    for _, ui in pairs(vim.api.nvim_list_uis()) do
        if ui.chan and not ui.stdout_tty then
            vim.fn.chanclose(ui.chan)
        end
    end
end)

map('n', '<leader>sv', function()
    -- source: https://github.com/creativenull
    for name, _ in pairs(package.loaded) do
        if name:match('^user') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify("Config reloaded", vim.log.levels.INFO)
end)

-- URL handling
-- source: https://sbulav.github.io/vim/neovim-opening-urls/
if vim.fn.has("mac") == 1 then
    map("", "gx", '<Cmd>call jobstart(["open", expand("<cfile>")], {"detach": v:true})<CR>', {})
elseif vim.fn.has("unix") == 1 then
    map("", "gx", '<Cmd>call jobstart(["xdg-open", expand("<cfile>")], {"detach": v:true})<CR>', {})
else
    map("", "gx", '<Cmd>lua print("Error: gx is not supported on this OS!")<CR>')
end
