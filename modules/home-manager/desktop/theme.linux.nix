{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf pkgs.hostPlatform.isLinux {
    gtk = {
      enable = true;
      catppuccin = {
        enable = true;
        size = "compact";
        tweaks = [ "rimless" ];
      };
      iconTheme = {
        package = pkgs.unstable.catppuccin-papirus-folders;
        name = "Papirus-Dark";
      };
    };

    home.pointerCursor = {
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.unstable.catppuccin-cursors.mochaDark;
      size = 24;
      gtk.enable = true;
    };

    assertions = [
      (
        let
          themes = builtins.readDir "${config.home.pointerCursor.package}/share/icons";
        in
        {
          assertion = themes.${config.home.pointerCursor.name} == "directory";
          message = ''${config.home.pointerCursor.name} not found in cursor theme: ${builtins.toJSON themes}'';
        }
      )
    ];
  };
}
