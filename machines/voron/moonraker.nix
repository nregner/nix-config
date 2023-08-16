{
  nixpkgs.overlays = [ (final: prev: { inherit (final.unstable) moonraker; }) ];

  # required for allowSystemControl
  security.polkit.enable = true;

  services.moonraker = {
    enable = true;
    allowSystemControl = true;

    settings = {
      authorization = {
        cors_domains = [ "*://voron.nregner.net" "*://voron" ];
        trusted_clients = [ "127.0.0.0/8" "::1/128" ];
      };
      history = { };
    };
  };
}
