{ config, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;
    extraLuaConfig = ''
      vim.g.copilot_node_command = '${pkgs.unstable.nodejs_20}/bin/node'
      require('user')
    '';

    plugins = with pkgs.unstable.vimPlugins; [ lazy-nvim ];

    extraPackages = with pkgs.unstable; [

      # language servers
      clojure-lsp
      gopls
      lua-language-server
      nil
      nixd
      nodePackages_latest.graphql-language-service-cli
      nodePackages_latest.typescript-language-server
      nodePackages_latest.volar
      terraform-ls

      # formatters/linters
      codespell
      nodePackages_latest.prettier
      (prettierd.overrideAttrs {
        src = fetchFromGitHub {
          owner = "fsouza";
          repo = "prettierd";
          rev = "0d077fe55711bba2c6c6756a953cf04e5acce86c";
          hash = "sha256-EQHnQo8NQLP1+2QmtmeV4t/b1yFmrwC6Fdoe69/QEAE=";
        };
      })
      stylua

      # misc
      clang # for compiling tree-sitter parsers
    ];
  };

  xdg.configFile = {
    "nvim/lua".source = config.lib.file.mkFlakeSymlink ./lua;
    "nvim/lazy-lock.json".source =
      config.lib.file.mkFlakeSymlink ./lazy-lock.json;
  };

  # https://github.com/sindrets/diffview.nvim/issues/324
  programs.git.extraConfig = {
    diff.tool = "nvim";
    difftool = {
      prompt = false;
      nvim.cmd = ''nvim -d \"$LOCAL\" \"$REMOTE\" -c \"DiffviewOpen\"'';
    };
    merge = { tool = "nvim"; };
    mergetool = {
      prompt = false;
      keepBackup = false;
      nvim.cmd = ''nvim -n -c "DiffviewOpen" "$MERGE"'';
    };
  };

  programs.zsh.shellAliases = { vimdiff = "nvim -d"; };
}
