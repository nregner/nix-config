{ inputs, config, ... }: {
  programs.k9s = {
    enable = true;
    settings.ui.skin = "catppuccin-mocha";
    skins.catppuccin-mocha = config.lib.formats.fromYAML
      "${inputs.catppuccin-k9s}/dist/catppuccin-mocha.yaml";
  };
}
