return {
  {
    "Olical/conjure",
    ft = { "clojure" },
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "conjure-log-*.cljc" },
        callback = function(ev)
          vim.diagnostic.disable(ev.buf)
        end,
      })
    end,
  },

  -- Structural editing, optional
  -- https://github.com/guns/vim-sexp
  "guns/vim-sexp",

  -- https://github.com/tpope/vim-sexp-mappings-for-regular-people
  "tpope/vim-sexp-mappings-for-regular-people",
}
