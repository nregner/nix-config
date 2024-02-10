{ inputs, config, pkgs, ... }: {
  imports = [ inputs.mealie.nixosModules.default ];

  services.mealie = {
    enable = true;
    package = inputs.mealie.packages.${pkgs.stdenv.hostPlatform.system}.mealie;
  };

  nginx.subdomain.mealie = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}/";
  };

  services.backups.mealie = {
    paths = [ config.services.mealie.stateDir ];
    restic = { s3 = { }; };
  };
}
