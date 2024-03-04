{ config, pkgs, lib, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.unstable;
    [
      # nerdfonts is large - just use a subset
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

  gtk = {
    enable = pkgs.hostPlatform.isLinux;
    theme = {
      # nix build .\#homeConfigurations.nregner@iapetus.config.gtk.theme.package
      # ls result/share/themes
      name = "Catppuccin-Mocha-Compact-Blue-Dark";
      package = pkgs.unstable.catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };
  };

  home.pointerCursor = lib.mkIf pkgs.hostPlatform.isLinux {
    name = "Catppuccin-Mocha-Dark-Cursors";
    package = pkgs.unstable.catppuccin-cursors.mochaDark;
    size = 24;
    gtk.enable = true;
  };

  # https://github.com/catppuccin/gtk
  xdg.configFile = lib.mkIf pkgs.hostPlatform.isLinux {
    "gtk-4.0/assets".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source =
      "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };
}
