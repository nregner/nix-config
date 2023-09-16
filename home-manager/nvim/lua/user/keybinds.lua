-- https://github.com/neovim/neovim/issues/23093
vim.keymap.set('n', '<leader>ex', function()
    for _, ui in pairs(vim.api.nvim_list_uis()) do
        if ui.chan and not ui.stdout_tty then
            vim.fn.chanclose(ui.chan)
        end
    end
end)

vim.keymap.set('n', '<leader>sv', function()
    -- source: https://github.com/creativenull
    for name, _ in pairs(package.loaded) do
        if name:match('^user') then
            package.loaded[name] = nil
        end
    end

    dofile(vim.env.MYVIMRC)
    vim.notify("Config reloaded", vim.log.levels.INFO)
end)
