-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- https://github.com/folke/lazy.nvim#-plugin-spec
require("lazy").setup({
  -- Git
  "tpope/vim-fugitive",
  "tpope/vim-rhubarb",

  -- replacement for ":w !sudo tee % > /dev/null" trick
  "lambdalisue/vim-suda",

  -- {
  --   "akinsho/git-conflict.nvim",
  --   version = "*",
  --   config = true,
  -- },

  -- https://github.com/sindrets/diffview.nvim#configuration
  {
    "sindrets/diffview.nvim",
    dev = true,
    opts = {
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
  },

  {
    "/chentoast/marks.nvim",
    config = true,
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim",
    },
    config = true,
  },

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- Autoclose/Autoescape
  {
    "altermo/ultimate-autopair.nvim",
    event = { "InsertEnter", "CmdlineEnter" },
    branch = "v0.6", --recommended as each new version will have breaking changes
    opts = {
      cmap = false,
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    lazy = false,
    config = function()
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end

      require("ufo").setup({
        open_fold_hl_timeout = 150,
        close_fold_kinds_for_ft = {
          default = { "imports", "comment" },
        },
        preview = {
          win_config = {
            winblend = 0,
          },
          mappings = {
            close = "q",
            switch = "K",
          },
        },
        fold_virt_text_handler = handler,
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end)
    end,
  },

  { -- Notifications + LSP Progress Messages
    "j-hui/fidget.nvim",
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
  },

  { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = { "j-hui/fidget.nvim", "yioneko/nvim-vtsls" },
    config = function()
      local on_attach = function(_, bufnr)
        local map = function(mode, keys, func, desc)
          if desc then
            desc = "LSP: " .. desc
          end

          vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
        end

        local nmap = function(keys, func, desc)
          map("n", keys, func, desc)
        end

        nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        nmap("<leader>fci", vim.lsp.buf.incoming_calls, "[F]ind [C]allers [I]ncoming")
        nmap("<leader>fca", vim.lsp.buf.outgoing_calls, "[F]ind [C]allers [O]outgoing")

        nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

        -- See `:help K` for why this keymap
        -- nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<M-k>", vim.lsp.buf.signature_help, "Signature Documentation")

        -- Lesser used LSP functionality
        nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
        nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
        nmap("<leader>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "[W]orkspace [L]ist Folders")

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
          vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
      end

      require("lspconfig.configs").vtsls = require("vtsls").lspconfig -- set default server config, optional but recommended

      local servers = {
        clojure_lsp = {},
        emmet_language_server = {},
        eslint = {},
        gopls = {},
        graphql = {},
        html = { filetypes = { "html", "twig", "hbs" } },
        jsonls = {
          -- https://github.com/b0o/SchemaStore.nvim?tab=readme-ov-file
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
        nil_ls = {},
        nushell = {},
        rust_analyzer = {
          -- https://rust-analyzer.github.io/manual.html#configuration
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            completion = {
              autoimport = { enable = true },
            },
            files = {
              excludeDirs = { ".direnv", ".git" },
            },
          },
        },
        terraformls = {},
        volar = {},
        vtsls = {
          settings = require("vtsls").lspconfig.settings,
        },
        yamlls = {
          yaml = {
            -- https://github.com/b0o/SchemaStore.nvim?tab=readme-ov-file
            schemaStore = {
              -- You must disable built-in schemaStore support if you want to use
              -- this plugin and its advanced options like `ignore`.
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = "",
            },
            schemas = require("schemastore").yaml.schemas(),
          },
        },

        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            -- diagnostics = { disable = { 'missing-fields' } },
          },
        },
      }

      -- FIXME
      -- Hide all semantic highlights
      for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
        vim.api.nvim_set_hl(0, group, {})
      end

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      for server_name, server_config in pairs(servers) do
        require("lspconfig")[server_name].setup({
          capabilities = capabilities,
          on_attach = on_attach,
          settings = server_config,
          filetypes = (server_config or {}).filetypes,
        })
      end
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    dependencies = { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },

  "b0o/schemastore.nvim",

  { -- LSP output panel
    "mhanberg/output-panel.nvim",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup()
    end,
  },

  { -- Autoformat
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
        lua = { "stylua" },
        markdown = { "prettierd", "injected" },
        nix = { "nixfmt" },
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
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
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
  },

  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = "CC=clang make install_jsregexp",
        dependencies = {
          -- https://github.com/rafamadriz/friendly-snippets
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      -- FIXME: broken
      luasnip.config.setup({
        load_ft_func = require("luasnip.extras.filetype_functions").extend_load_ft({
          typescript = { "javascript" },
          javascriptreact = { "javascript" },
          typescriptreact = { "typescript", "javascriptreact" },
          html = { "javascript", "css" },
          vue = { "javascript", "css" },
        }),
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_next_item()
            else
              cmp.complete({
                config = {
                  sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                  },
                },
              })
            end
          end),
          -- ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),

          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),

          -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if not entry then
                cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
              end
              cmp.confirm({
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              })
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "luasnip" },
          { name = "nvim_lsp" },
          {
            name = "buffer",
            keyword_length = 5,
            -- option = {
            --   get_bufnrs = function()
            --     local bufs = {}
            --     for _, win in ipairs(vim.api.nvim_list_wins()) do
            --       bufs[vim.api.nvim_win_get_buf(win)] = true
            --     end
            --     return vim.tbl_keys(bufs)
            --   end,
            -- },
          },
          { name = "path" },
        },
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.kind,
          },
        },
      })
    end,
  },

  {
    "huggingface/llm.nvim",
    opts = {
      backend = "ollama",
      model = "codegemma:2b",
      url = "http://localhost:11434", -- llm-ls uses "/api/generate"
      -- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
      request_body = {
        -- -- Modelfile options for the model you use
        -- options = {
        --   temperature = 0.2,
        --   top_p = 0.95,
        -- },
      },
    },
  },

  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   opts = {
  --     copilot_node_command = vim.g.copilot_node_command,
  --     panel = {
  --       enabled = true,
  --       auto_refresh = true,
  --     },
  --     suggestion = {
  --       enabled = true,
  --       auto_trigger = true,
  --     },
  --     filetypes = {
  --       yaml = true,
  --       markdown = true,
  --       gitcommit = true,
  --       gitrebase = true,
  --     },
  --   },
  -- },

  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
      require("which-key").register({
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "More git", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
      })
    end,
  },

  -- https://github.com/mbbill/undotree#configuration
  {
    "mbbill/undotree",
    keys = {
      { "<leader>fu", vim.cmd.UndotreeToggle, desc = "[F]ile [U]ndo Tree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 4
    end,
  },

  {
    -- https://github.com/lewis6991/gitsigns.nvim
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "<leader>hs", gs.stage_hunk, { desc = "[H]unk [S]tage" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "[H]unk [R]eset" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[H]unk [S]tage" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[H]unk [R]eset" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "[H]unk [S]tage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "[H]unk [U]ndo stage" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "[H]unk [R]eset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "[H]unk [P]review" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "[H]unk [B]lame" })
        map("n", "<leader>hB", gs.toggle_current_line_blame, { desc = "Git [B]lame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "[H]unk [D]iff" })
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, { desc = "[H]unk [D]iff last commit" })
        map("n", "<leader>htd", gs.toggle_deleted, { desc = "[H]unk [T]oggle [D]eleted" })

        -- don't override the built-in and fugitive keymaps
        map({ "n", "v" }, "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to next hunk" })
        map({ "n", "v" }, "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Jump to previous hunk" })
      end,
    },
  },

  { -- Theme
    -- https://github.com/catppuccin/nvim
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      styles = {
        conditionals = {}, -- disable italics
      },
    },
    init = function()
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- https://github.com/stevearc/dressing.nvim
  {
    "stevearc/dressing.nvim",
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        icons_enabled = false,
        theme = "catppuccin",
        component_separators = "|",
        disabled_filetypes = { "NvimTree" },
      },
      sections = {
        lualine_a = {
          "mode",
          function()
            local reg = vim.fn.reg_recording()
            if reg == "" then
              return ""
            end
            return "recording to " .. reg
          end,
        },
        lualine_b = { "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "catgoose/telescope-helpgrep.nvim",
    },
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      require("telescope").setup({
        defaults = {
          preview = {
            enabled = false,
            -- try to prevent freezes on large files
            -- https://github.com/nvim-telescope/telescope.nvim/issues/1379
            filesize_limit = 1, -- MB
            highlight_limit = 0.1, -- MB
          },
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden", -- added to default
          },
          mappings = {
            i = {
              ["<c-enter>"] = "to_fuzzy_refine",
              -- map actions.which_key to <C-h> (default: <C-/>)
              -- actions.which_key shows the mappings for your picker,
              -- e.g. git_{create, delete, ...}_branch for the git_branches picker
              -- ["<C-h>"] = "which_key",
            },
            n = {
              ["d"] = "delete_buffer",
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          git_commits = {
            mappings = {
              i = {
                ["<C-d>"] = function() -- show diffview for the selected commit
                  -- Open in diffview
                  local entry = action_state.get_selected_entry()
                  -- close Telescope window properly prior to switching windows
                  actions.close(vim.api.nvim_get_current_buf())
                  vim.cmd(("DiffviewOpen %s^!"):format(entry.value))
                end,
              },
            },
          },
          git_bcommits = {
            mappings = {
              i = {
                ["<C-d>"] = function() -- show diffview for the selected commit of current buffer
                  -- Open in diffview
                  local entry = action_state.get_selected_entry()
                  -- close Telescope window properly prior to switching windows
                  actions.close(vim.api.nvim_get_current_buf())
                  vim.cmd(("DiffviewOpen %s^!"):format(entry.value))
                end,
              },
            },
          },
          git_branches = {
            mappings = {
              i = {
                ["<C-d>"] = function() -- show diffview comparing the selected branch with the current branch
                  -- Open in diffview
                  local entry = action_state.get_selected_entry()
                  -- close Telescope window properly prior to switching windows
                  actions.close(vim.api.nvim_get_current_buf())
                  vim.cmd(("DiffviewOpen %s.."):format(entry.value))
                end,
              },
            },
          },
        },
        extensions = {
          helpgrep = {
            ignore_paths = {
              vim.fn.stdpath("state") .. "/lazy/readme",
            },
          },
        },
      })

      require("telescope").load_extension("fzf")
      require("telescope").load_extension("helpgrep")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
      vim.keymap.set("n", "<leader>fd", function()
        builtin.diagnostics({ sort_by = "severity" })
      end, { desc = "[F]ind [D]iagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
      vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><space>", function()
        require("telescope.builtin").buffers({ sort_lastused = true, ignore_current_buffer = true })
      end, { desc = "[ ] Find existing buffers" })
      vim.keymap.set(
        "n",
        "<leader>fc",
        require("telescope.builtin").command_history,
        { desc = "[F]ind [C]ommand History" }
      )

      -- Git
      vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "[G]it [B]ranches" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
      vim.keymap.set("n", "<leader>gf", builtin.git_bcommits, { desc = "[G]it [F]ile Commits" })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set("n", "<leader>/", function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          -- winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>f/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[F]ind [/] in Open Files" })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>fn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[F]ind [N]eovim files" })
    end,
  },

  {
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nushell/tree-sitter-nu",
    },
    build = ":TSUpdate",
    keys = {
      {
        "[C",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        silent = true,
      },
    },
    lazy = false,
    opts = {
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "v",
          node_decremental = "V",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>a"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>A"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      require("treesitter-context").setup({
        max_lines = 10,
        multiline_threshold = 1,
        -- mode = "topline",
      })

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  {
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
    opts = function()
      local view_width_max = 30
      return {
        update_cwd = true,
        sync_root_with_cwd = true,
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
          local git = require("nvim-tree.git")
          local utils = require("nvim-tree.utils")

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

          local function toggle_adaptive_width()
            print("view_width_max", view_width_max)
            if view_width_max == -1 then
              view_width_max = 30
            else
              view_width_max = -1
            end
            api.tree.reload()
          end

          vim.keymap.set("n", "A", toggle_adaptive_width, opts("Toggle [A]daptive Width"))

          local function cd_git_root()
            local node = api.tree.get_node_under_cursor()
            if node then
              if node.type == "file" then
                node = node.parent
              end
              local toplevel = git.get_toplevel(node.absolute_path)
              api.tree.change_root(toplevel)
            end
            api.tree.reload()
          end

          vim.keymap.set("n", "~", cd_git_root, opts("CD to Git Root"))

          local function edit_or_open()
            local node = api.tree.get_node_under_cursor()
            if node.nodes ~= nil then
              api.node.open.edit()
              if node.nodes[1] then
                utils.focus_file(node.nodes[1].absolute_path)
              end
            else
              api.node.open.edit()
            end
            api.tree.focus()
          end

          vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))

          vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close"))
          vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
        end,
      }
    end,
  },

  {
    {
      "antosha417/nvim-lsp-file-operations",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-tree.lua",
      },
      config = function()
        require("lsp-file-operations").setup()
      end,
    },
  },

  {
    "numToStr/Navigator.nvim",
    opts = {
      -- Save modified buffer(s) when moving to mux
      auto_save = "all",
    },
    init = function()
      vim.keymap.set({ "n", "t" }, "<C-h>", "<CMD>NavigatorLeft<CR>")
      vim.keymap.set({ "n", "t" }, "<C-l>", "<CMD>NavigatorRight<CR>")
      vim.keymap.set({ "n", "t" }, "<C-k>", "<CMD>NavigatorUp<CR>")
      vim.keymap.set({ "n", "t" }, "<C-j>", "<CMD>NavigatorDown<CR>")
    end,
  },

  "tpope/vim-repeat",

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    opts = {},
  },

  { -- Comment.nvim
    "numToStr/Comment.nvim",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", opts = { enable_autocmd = false } },
    },
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  {
    "ldelossa/litee.nvim",
    event = "VeryLazy",
    opts = {
      notify = { enabled = false },
      panel = {
        orientation = "bottom",
        panel_size = 10,
      },
    },
    config = function(_, opts)
      require("litee.lib").setup(opts)
    end,
  },

  { -- Calltree
    "ldelossa/litee-calltree.nvim",
    dependencies = "ldelossa/litee.nvim",
    event = "VeryLazy",
    opts = {
      on_open = "panel",
      keymaps = {
        expand = "l",
        collapse = "h",
        collapse_all = "H",
      },
    },
    config = function(_, opts)
      require("litee.calltree").setup(opts)
    end,
  },

  { -- TODO comments
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
      keywords = {
        TEST = nil,
      },
    },
  },

  { -- Colorizer
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    cmd = "ColorizerToggle",
    opts = {
      "*", -- Highlight all files
      "!TelescopePrompt", -- Except telescope previews. Seems to result in freezes: https://github.com/nvim-telescope/telescope.nvim/issues/1379
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- "Name" codes like Blue
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = true, -- CSS hsl() and hsla() functions
      css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
      css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
    },
    config = function(_, opts)
      require("colorizer").setup({ "*" }, opts)
    end,
  },

  { -- Neotest
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- Adapters
      "nvim-neotest/neotest-jest",
      "rouge8/neotest-rust",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-rust")({
            args = { "--no-capture", "--cargo-quiet", "--cargo-quiet" },
          }),
          require("neotest-jest")({}),
        },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.WARN,
        },
        output = {
          open_on_run = true,
          enter = true,
        },
      })

      -- :run_all_tests "ta"
      -- :run_current_ns_tests "tn"
      -- :run_alternate_ns_tests "tN"
      -- :run_current_test "tc"
      local nmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = desc })
      end

      local show_summary = function()
        neotest.summary.open()
      end

      nmap("<localleader>tt", function(args)
        neotest.run.run(args)
        show_summary()
      end, "[T]est [T]his")
      nmap("<localleader>tf", function()
        neotest.run.run(vim.fn.expand("%"))
        show_summary()
      end, "[T]est [F]ile")
      nmap("<localleader>tq", function()
        neotest.run.stop()
        neotest.watch.stop()
        neotest.summary.close()
      end, "[T]est [Q]uit")
      nmap("<localleader>twt", function()
        neotest.watch.watch()
        show_summary()
      end, "[T]est [W]atch [T]his")
      nmap("<localleader>twq", function()
        neotest.watch.stop()
      end, "[T]est [W]atch [Q]uit")
    end,
  },

  { -- trouble.nvim
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = {
      "smoka7/hydra.nvim",
    },
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "v", "n" },
        "<Leader>m",
        "<cmd>MCstart<cr>",
        desc = "Create a selection for selected text or word under the cursor",
      },
    },
  },

  { -- REPL
    "Olical/conjure",
    ft = { "clojure" },
    dependencies = {
      -- https://github.com/guns/vim-sexp
      "guns/vim-sexp",
      -- https://github.com/tpope/vim-sexp-mappings-for-regular-people
      "tpope/vim-sexp-mappings-for-regular-people",
      {
        "PaterJason/cmp-conjure",
        config = function()
          local cmp = require("cmp")
          local config = cmp.get_config()
          table.insert(config.sources, {
            name = "buffer",
            option = {
              sources = {
                { name = "conjure" },
              },
            },
          })
          cmp.setup(config)
        end,
      },
    },
    config = function(_)
      require("conjure.main").main()
      require("conjure.mapping")["on-filetype"]()
    end,
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { "conjure-log-*.cljc" },
        callback = function(ev)
          vim.diagnostic.disable(ev.buf)
        end,
      })
      vim.g["conjure#extract#tree_sitter#enabled"] = true
    end,
  },
}, {
  dev = {
    path = "~/dev/github/",
  },
})

-- https://trstringer.com/neovim-auto-reopen-files/
vim.api.nvim_create_autocmd("VimLeavePre", {
  pattern = "*",
  callback = function()
    if vim.g.savesession then
      vim.api.nvim_command("mks!")
    end
  end,
})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.foldcolumn = "0"
vim.o.foldlevel = 99 -- ufo needs a large value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Remap record macro to prevent accidental presses
vim.keymap.set("n", "<leader>q", "q", { noremap = true })
vim.keymap.set("n", "q", "<nop>", { noremap = true })

-- Diagnostic keymaps

-- https://github.com/neovim/neovim/discussions/25588#discussioncomment-8700283
local function pos_equal(p1, p2)
  local r1, c1 = unpack(p1)
  local r2, c2 = unpack(p2)
  return r1 == r2 and c1 == c2
end

local function goto_error_diagnostic(f)
  return function()
    local pos_before = vim.api.nvim_win_get_cursor(0)
    f({ severity = vim.diagnostic.severity.ERROR, wrap = true })
    local pos_after = vim.api.nvim_win_get_cursor(0)
    if pos_equal(pos_before, pos_after) then
      f({ wrap = true })
    end
  end
end

vim.keymap.set("n", "[e", goto_error_diagnostic(vim.diagnostic.goto_prev), { desc = "Go to previous error diagnostic" })
vim.keymap.set("n", "]e", goto_error_diagnostic(vim.diagnostic.goto_next), { desc = "Go to next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

vim.keymap.set("n", "<leader>sv", function()
  -- source: https://github.com/creativenull
  for name, _ in pairs(package.loaded) do
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end
  dofile(vim.env.MYVIMRC)
  vim.notify("Config reloaded", vim.log.levels.INFO)
end, { desc = "[S]ource [V]imrc" })

-- Quickfix keymaps
vim.keymap.set("n", "[q", "<CMD>cprev<CR>", { desc = "Go to previous quickfix item" })
vim.keymap.set("n", "]q", "<CMD>cnext<CR>", { desc = "Go to next quickfix item" })
vim.keymap.set("n", "[Q", "<CMD>cfirst<CR>", { desc = "Go to first quickfix item" })
vim.keymap.set("n", "]Q", "<CMD>clast<CR>", { desc = "Go to last quickfix item" })

-- URL handling
-- source: https://sbulav.github.io/vim/neovim-opening-urls/
if vim.fn.has("mac") == 1 then
  vim.keymap.set("", "gx", function()
    vim.fn.jobstart("open " .. vim.fn.shellescape(vim.fn.expand("<cfile>")), { detach = true })
  end)
elseif vim.fn.has("unix") == 1 then
  vim.keymap.set("", "gx", function()
    vim.fn.jobstart("xdg-open " .. vim.fn.shellescape(vim.fn.expand("<cfile>")), { detach = true })
  end)
else
  vim.keymap.set("", "gx", '<Cmd>lua print("Error: gx is not supported on this OS!")<CR>')
end

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require("telescope.builtin").live_grep({
      search_dirs = { git_root },
    })
  end
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
