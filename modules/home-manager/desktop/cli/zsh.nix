{
  programs.zsh = {
    enable = true;

    syntaxHighlighting = {
      enable = true;
      catppuccin.enable = true;
    };

    initExtra = builtins.readFile ./zshrc.zsh;
  };
}
