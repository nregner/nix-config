{ inputs, config, lib, ... }: {
  imports = [ inputs.hydra-sentinel.darwinModules.client ];

  options.nregner.hydra-builder = {
    enable = lib.mkEnableOption "Register this machine as a Hydra builder";
  };

  config = lib.mkIf config.nregner.hydra-builder.enable {
    services.hydra-sentinel-client = {
      enable = true;
      settings = { server_addr = "sagittarius:3002"; };
    };
  };
}
