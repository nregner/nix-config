{ inputs, pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs.unstable; [
    # nerdfonts is large - use a subset
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    comma # auto-run from nix-index: https://github.com/nix-community/comma
    nix-output-monitor
    nix-prefetch
    nixfmt
    nix-du # nix-du -s=500MB | xdot -
    xdot
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${inputs.catppuccin-alacritty}/catppuccin-mocha.yml" ];
      selection = { save_to_clipboard = true; };
      window = { dynamic_padding = true; };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11;
      };
    };
  };
}
