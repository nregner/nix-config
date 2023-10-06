{ config, pkgs, ... }: {
  xdg.configFile."nvim/lua".source = config.lib.file.mkFlakeSymlink ./lua;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;
    extraLuaConfig = ''
      require('user')
    '';

    plugins = with pkgs.unstable.vimPlugins; [
      # theme
      catppuccin-nvim

      # tmux <-> nvim navigation 
      Navigator-nvim

      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''
          require('colorizer').setup({})
        '';
      }

      lualine-nvim

      nvim-treesitter.withAllGrammars
      plenary-nvim
      mini-nvim
      vim-surround
      nvim-tree-lua
      telescope-nvim
      telescope-fzy-native-nvim
      nvim-lspconfig

      vim-nix # File type and syntax highlighting.
      luasnip
      nvim-cmp
      cmp_luasnip
      cmp-nvim-lsp
      nvim-lspconfig
      fidget-nvim
      vim-just
      vim-fugitive
      conflict-marker-vim
    ];
  };

  programs.git.extraConfig = {
    merge = { tool = "vimdiff"; };
    mergetool.vimdiff = {
      cmd = "nvim -d $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
    };
  };

  home.packages = with pkgs.unstable; [
    # just get from rustup for now
    # rust-analyzer
    nil
    terraform-ls
    lua-language-server
  ];
}
