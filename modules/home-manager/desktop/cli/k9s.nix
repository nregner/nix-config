{ config, pkgs, ... }:
{
  programs.k9s = {
    enable = true;
    package = pkgs.unstable.k9s;
    catppuccin.enable = true;
  };

  xdg.enable = true;

  # lazy fix for mismatched config path on darwin
  imports = [
    (
      { pkgs, lib, ... }:
      {
        config = lib.mkIf pkgs.stdenv.isDarwin {
          home.file."Library/Application Support/k9s".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/k9s";
        };
      }
    )
  ];
}
