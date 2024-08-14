{ config, pkgs, ... }:
let
  dataDir = "/var/lib/mealie";
in
{
  services.mealie = {
    enable = true;
    package = pkgs.unstable.mealie.overrideAttrs (old: {
      # FIXME: https://github.com/NixOS/nixpkgs/issues/321623
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/mealie-recipes/mealie/commit/65ece35966120479db903785b22e9f2645f72aa4.patch";
          hash = "sha256-4Nc0dFJrZ7ElN9rrq+CFpayKsrRjRd24fYraUFTzcH8=";
        })
      ];
      doCheck = false;
    });
  };

  nginx.subdomain.mealie = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}/";
  };

  services.nregner.backup.paths.mealie = {
    paths = [ dataDir ];
    restic = {
      s3 = { };
    };
  };

  assertions = [
    {
      assertion = config.systemd.services.mealie.environment.DATA_DIR == dataDir;
      message = ''
        Mismatched config.systemd.services.mealie.environment.DATA_DIR: ${config.systemd.services.mealie.environment.DATA_DIR}
      '';
    }
  ];
}
