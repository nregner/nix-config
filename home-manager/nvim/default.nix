{ config, lib, pkgs, ... }: {
  xdg.configFile."nvim/lua".source = config.lib.file.mkOutOfStoreSymlink ./lua;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;

    plugins = with pkgs.unstable.vimPlugins; [
      {
        plugin = nvim-base16;
        type = "lua";
        config = ''
          require('base16-colorscheme').setup({
          ${
            let colors = config.lib.stylix.colors;
            in lib.concatStrings
            (map (i: "  base0${i} = '#${colors.${"base0${i}-hex"}}',\n") [
              "0"
              "1"
              "2"
              "3"
              "4"
              "5"
              "6"
              "7"
              "8"
              "9"
              "A"
              "B"
              "C"
              "D"
              "E"
              "F"
            ])
          }})

          -- TODO: Better way to order configs?
          require('user')
        '';
      }

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

      lualine-nvim
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
