{
  # catppuccin.zsh-syntax-highlighting.enable = true;
  programs.zsh = {
    enable = true;
    initExtra = builtins.readFile ./zshrc.zsh;
    syntaxHighlighting.enable = true;
  };
}
