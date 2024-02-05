{ inputs, config, ... }: {
  programs.k9s = {
    enable = true;
    skins.skin = config.lib.formats.fromYAML
      "${inputs.catppuccin-k9s}/dist/catppuccin-mocha.yaml";
  };
}
