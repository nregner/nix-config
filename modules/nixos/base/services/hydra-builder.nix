{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [ inputs.hydra-sentinel.nixosModules.client ];

  options.services.nregner.hydra-builder = {
    enable = lib.mkEnableOption "Register this machine as a Hydra builder";
  };

  config = lib.mkIf config.services.nregner.hydra-builder.enable {
    services.hydra-sentinel-client = {
      enable = true;
      settings = {
        server_addr = "sagittarius:3002";
      };
    };
  };
}
