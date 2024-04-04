{ inputs, config, pkgs, ... }: {
  imports = [ inputs.mealie.nixosModules.default ];

  services.mealie-nightly = {
    enable = true;
    package =
      inputs.mealie.packages.${pkgs.stdenv.hostPlatform.system}.mealie-nightly;
  };

  nginx.subdomain.mealie = {
    "/".proxyPass =
      "http://127.0.0.1:${toString config.services.mealie-nightly.port}/";
  };

  services.backups.mealie = {
    paths = [ config.services.mealie-nightly.stateDir ];
    restic = { s3 = { }; };
  };

  # nix.settings = {
  #   substituters = [ "https://nathanregner-mealie-nix.cachix.org" ];
  #   trusted-public-keys = [
  #     "nathanregner-mealie-nix.cachix.org-1:Ir3Z9UXjCcKwULpHZ8BveGbg7Az7edKLs4RPlrM1USM="
  #   ];
  # };
}
