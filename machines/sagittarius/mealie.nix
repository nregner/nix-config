{ inputs, config, pkgs, ... }: {
  imports = [ inputs.mealie.nixosModules.default ];

  services.mealie-nightly = {
    enable = true;
    package = inputs.mealie.packages.${pkgs.stdenv.hostPlatform.system}.mealie;
  };

  nginx.subdomain.mealie = {
    "/".proxyPass =
      "http://127.0.0.1:${toString config.services.mealie-nightly.port}/";
  };

  services.backups.mealie = {
    paths = [ config.services.mealie-nightly.stateDir ];
    restic = { s3 = { }; };
  };
}
