{ inputs, pkgs, ... }: {
  imports = [ inputs.stylix.homeManagerModules.stylix ];

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # image = "${pkgs.gnome.gnome-backgrounds}/gnome/blobs-d.svg";
    fonts = {
      monospace = {
        # nerdfonts is large - pull in the ones we care about
        package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
        name = "JetBrainsMono Nerd Font";
      };
    };
    autoEnable = false;
    targets = {
      alacritty.enable = true;
      fzf.enable = true;
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      selection = { save_to_clipboard = true; };
      window = { dynamic_padding = true; };
    };
  };
}
