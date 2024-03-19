{ config, pkgs, lib, ... }:
let
  cfg = config.programs.tmux-sessionizer;
  tomlFormat = pkgs.formats.toml { };

  configDir = if pkgs.stdenv.isDarwin then
    "Library/Application Support"
  else
    config.xdg.configHome;
in {
  options.programs.tmux-sessionizer = {
    enable = lib.mkEnableOption "Enable tmux-sessionizer";
    settings = lib.mkOption {
      type = tomlFormat.type;
      default = {
        session_sort_order = "LastAttached";
        search_dirs = [{
          path = "${config.home.homeDirectory}/dev";
          depth = 2;
        }];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unstable.tmux-sessionizer ];
    home.file."${configDir}/tms/config.toml".source =
      tomlFormat.generate "tms-config" cfg.settings;
  };
}
