return { -- Autoformat
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			bash = { "shfmt" },
			clojure = { "joker" },
			css = { "prettierd" },
			gitcommit = { "prettier", "injected" }, -- FIXME: prettierd erroring out
			go = { "gofmt" },
			graphql = { "prettierd" },
			html = { "prettierd" },
			javascript = { "prettierd" },
			javascriptreact = { "prettierd" },
			json = { "prettierd" },
			jsonc = { "prettierd" },
			lua = { "stylua" },
			markdown = { "prettierd", "injected" },
			nginx = { "nginxfmt" },
			nix = { "nixfmt", "injected" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			terraform = { "terraform_fmt" },
			typescript = { "prettierd" },
			typescriptreact = { "prettierd" },
			vue = { "prettierd" },
			yaml = { "prettierd" },

			-- all filetypes
			["*"] = { "trim_whitespace" },

			-- unspecified filetypes
			["_"] = { "trim_whitespace" },
		},
		formatters = {
			prettier = { options = { ft_parsers = { gitcommit = "markdown" } } },
			nginxfmt = {
				command = "nginxfmt",
				args = { "--pipe" },
			},
		},
		format_on_save = function(bufnr)
			-- Disable with a global or buffer-local variable
			if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
				return
			end
			return { timeout_ms = 500, lsp_format = "fallback" }
		end,
	},
	config = function(_, opts)
		require("conform").setup(opts)

		vim.api.nvim_create_user_command("FormatDisable", function(args)
			if args.bang then
				vim.g.disable_autoformat = true
			else
				---@diagnostic disable-next-line: inject-field
				vim.b.disable_autoformat = true
			end
		end, {
			desc = "Disable autoformat-on-save",
			bang = true,
		})
		vim.api.nvim_create_user_command("FormatEnable", function(args)
			if args.bang then
				vim.g.disable_autoformat = false
			end
			---@diagnostic disable-next-line: inject-field
			vim.b.disable_autoformat = false
		end, {
			desc = "Re-enable autoformat-on-save",
		})
	end,
}
