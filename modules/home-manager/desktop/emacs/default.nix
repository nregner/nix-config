{
  programs.emacs = {
    enable = true;
    extraPackages =
      emacsPackages: builtins.attrValues { inherit (emacsPackages) catppuccin-theme evil evil-surround; };
  };
}
