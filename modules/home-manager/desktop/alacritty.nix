{ config, inputs, pkgs, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      import = [ "${config.xdg.configHome}/alacritty/theme.yml" ];
      selection = { save_to_clipboard = true; };
      window = { dynamic_padding = true; };
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        size = 11;
      };
      env = { TERM = "alacritty"; };
    };
  };

  xdg.configFile."alacritty/theme.yml".source =
    pkgs.runCommand "alacritty-theme" {
      nativeBuildInputs = [ pkgs.remarshal ];
    } ''
      remarshal ${inputs.catppuccin-alacritty}/catppuccin-mocha.toml -if toml -of yaml -o $out;
    '';
}
