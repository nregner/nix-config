{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.unstable; [
    # nerdfonts is large - use a subset
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    inter
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Lavender-Dark";
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/themes/catppuccin-gtk/default.nix#L16-L19
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };

    # iconTheme = {
    #   name = "Papirus";
    #   package = pkgs.unstable.catppuccin-papirus-folders.override {
    #     flavor = "mocha";
    #     accent = "blue";
    #   };
    # };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      package = pkgs.unstable.adwaita-qt;
      name = "adwaita-dark";
    };
  };

  # home.pointerCursor = {
  #   name = "Catppuccin-Mocha-Light-Cursors";
  #   package = pkgs.unstable.catppuccin-cursors;
  #   size = 24;
  #   gtk.enable = true;
  # };
}
