{ config, ... }: {
  programs.vim.enable = true;
  programs.vim.extraConfig = ''
    :so ${config.xdg.configHome}/vim/user.vim
  '';
  xdg.configFile."user.vim".source = config.lib.file.mkFlakeSymlink ./vimrc;
}
