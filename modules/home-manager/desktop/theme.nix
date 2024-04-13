{ config, pkgs, lib, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.unstable;
    [
      # nerdfonts is large - just use a subset
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

  gtk = {
    enable = pkgs.hostPlatform.isLinux;
    catppuccin = {
      enable = true;
      # accent = [ "blue" ];
      size = "compact";
      tweaks = [ "rimless" ];
      # variant = "mocha";
    };
    iconTheme = {
      package = pkgs.unstable.catppuccin-papirus-folders;
      name = "Papirus-Dark";
    };
  };

}
