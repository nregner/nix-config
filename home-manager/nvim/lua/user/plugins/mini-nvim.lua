require("mini.surround").setup({
    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
        add = 'ysa',           -- Add surrounding in Normal and Visual modes
        delete = 'ds',         -- Delete surrounding
        find = 'sf',           -- Find surrounding (to the right)
        find_left = 'sF',      -- Find surrounding (to the left)
        highlight = 'sh',      -- Highlight surrounding
        replace = 'cs',        -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`

        suffix_last = 'l',     -- Suffix to search with "prev" method
        suffix_next = 'n',     -- Suffix to search with "next" method
    },
})

require("mini.comment").setup({
    mappings = {
        -- Toggle comment (like `gcip` - comment inner paragraph) for both
        -- Normal and Visual modes
        comment = 'gc',

        -- Toggle comment on current line
        comment_line = 'gcc',

        -- Define 'comment' textobject (like `dgc` - delete whole comment block)
        textobject = 'gc',
    },
})
