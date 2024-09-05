{1 :stevearc/conform.nvim
 :config (fn [_ opts]
           ((. (require :conform) :setup) opts)
           (vim.api.nvim_create_user_command
             :FormatDisable (fn [args]
                              (if args.bang
                                  (set vim.g.disable_autoformat true)
                                  (set vim.b.disable_autoformat true)))
             {:bang true :desc "Disable autoformat-on-save"})
           (vim.api.nvim_create_user_command
             :FormatEnable (fn [args]
                             (when args.bang (set vim.g.disable_autoformat false))
                             (set vim.b.disable_autoformat false))
             {:desc "Re-enable autoformat-on-save"}))
 :opts {:format_on_save (fn [bufnr]
                          (when (not (or vim.g.disable_autoformat
                                         vim.b.bufnr.disable_autoformat))
                            {:lsp_format "fallback"
                             :timeout_ms 500}))
        :formatters {:nginxfmt {:args [:--pipe] :command :nginxfmt}
                     :prettier {:options {:ft_parsers {:gitcommit :markdown}}}}
        :formatters_by_ft {:* [:trim_whitespace]
                           :_ [:trim_whitespace]
                           :bash [:shfmt]
                           :clojure [:joker]
                           :css [:prettierd]
                           :gitcommit [:prettier :injected]
                           :go [:gofmt]
                           :graphql [:prettierd]
                           :html [:prettierd]
                           :javascript [:prettierd]
                           :javascriptreact [:prettierd]
                           :json [:prettierd]
                           :jsonc [:prettierd]
                           :lua [:stylua]
                           :markdown [:prettierd :injected]
                           :nginx [:nginxfmt]
                           :nix [:nixfmt :injected]
                           :rust [:rustfmt]
                           :sh [:shfmt]
                           :terraform [:terraform_fmt]
                           :typescript [:prettierd]
                           :typescriptreact [:prettierd]
                           :vue [:prettierd]
                           :yaml [:prettierd]}}}

