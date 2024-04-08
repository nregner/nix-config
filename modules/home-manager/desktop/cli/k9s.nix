{ inputs, config, pkgs, ... }:
let
  yamlFormat = pkgs.formats.yaml { };
  configDir = if (pkgs.stdenv.isDarwin) then
    "Library/Application Support/k9s"
  else
    "${config.xdg.configHome}/k9s";
in {
  home.packages = [ pkgs.unstable.k9s ];

  home.file."${configDir}/config.yaml".source =
    yamlFormat.generate "k9s-config" { k9s.ui.skin = "catppuccin"; };

  home.file."${configDir}/skins/catppuccin.yaml".source =
    "${inputs.catppuccin-k9s}/dist/catppuccin-mocha.yaml";

}
