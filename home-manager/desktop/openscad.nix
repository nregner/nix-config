{ inputs, pkgs, ... }: {
  home.packages = with pkgs.unstable; [ openscad openscad-lsp ];
  home.file.".local/share/OpenSCAD/libraries/BOSL".source = inputs.bosl;

  programs.neovim.plugins = with pkgs.unstable.vimPlugins; [{
    plugin = openscad-nvim; # https://github.com/salkin-mada/openscad.nvim
    type = "lua";
    config = ''
      vim.g.openscad_load_snippets = true
      vim.g.openscad_auto_open = true
      vim.g.openscad_cheatsheet_toggle_key = '<leader>h'
      vim.g.openscad_exec_openscad_trig_key = '<leader>o'
      require('openscad').setup({})
    '';
  }];
}
