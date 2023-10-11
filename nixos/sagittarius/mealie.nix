{ inputs, config, ... }: {
  imports = [ inputs.mealie.nixosModules.default ];

  nixpkgs.overlays = [ inputs.mealie.overlays.default ];

  services.mealie = { enable = true; };

  nginx.subdomain.mealie = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}/";
  };

  services.backups.mealie = {
    paths = [ config.services.mealie.stateDir ];
    restic = { s3 = { }; };
  };
}
