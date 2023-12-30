{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.unstable;
    [
      # nerdfonts is large - just use a subset
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
}
