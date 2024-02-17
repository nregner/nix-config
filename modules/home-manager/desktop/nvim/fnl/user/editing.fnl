; (fn pack [identifier ?options]
;   "A workaround around the lack of mixed tables in Fennel.
;   Has special `options` keys for enhanced utility.
;   See `:help themis.pack.lazy.pack` for information about how to use it."
;   (assert-compile (str? identifier) "expected string for identifier" identifier)
;   (assert-compile (or (nil? ?options) (table? ?options))
;                   "expected table for options" ?options)
;   (let [options (or ?options {})
;         options (collect [k v (pairs options)]
;                   (match k
;                     :require* (values :config `#(require ,v))
;                     _ (values k v)))]
;     (doto options (tset 1 identifier))))

[{1 :stevearc/conform.nvim
  :opts {:css [:prettierd]
         :fennel [:fnlfmt]
         :gitcommit [:prettier :injected]
         ; FIXME: prettierd erroring out
         :go [:gofmt]
         :html [:prettierd]
         :javascript [:prettierd]
         :javascriptreact [:prettierd]
         :json [:prettierd]
         :lua [:stylua]
         :markdown [:prettierd :injected]
         :nix [:nixfmt]
         :rust [:rustfmt]
         :terraform [:terraform_fmt]
         :typescript [:prettierd]
         :typescriptreact [:prettierd]
         :vue [:prettierd]
         :yaml [:prettierd]
         ; -- all filetypes
         :* [:trim_whitespace]
         ; -- unspecified filetypes
         :_ [:trim_whitespace]}
  :formatters {:prettier {:options {:ft_parsers {:gitcommit :markdown}}}}
  :format_on_save (fn [bufnr]
                    (when (not (or (get (nvim.buffers bufnr)
                                        :disable_autoformat)
                                   (get (nvim.globals) :disable_autoformat)))
                      {:timeout_ms 500 :lsp_fallback true}))}]

