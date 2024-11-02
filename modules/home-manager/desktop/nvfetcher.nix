{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.nvfetcher;
in
{
  options.programs.nvfetcher = {
    enable = lib.mkEnableOption "nvfetcher";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.unstable.nvfetcher ];

    sops.secrets.nvfetcher-keyfile = {
      sopsFile = ./secrets.yaml;
      key = "nvfetcher/keyfile";
    };

    programs.zsh.initExtra = ''
      export NVFETCHER_KEYFILE=${config.sops.secrets.nvfetcher-keyfile.path};
    '';
  };
}
