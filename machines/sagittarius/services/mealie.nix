{ config, pkgs, ... }:
let
  dataDir = "/var/lib/mealie";
in
{
  services.mealie = {
    enable = true;
    package =
      (pkgs.unstable.mealie.override {
        # FIXME: https://github.com/NixOS/nixpkgs/issues/325120
        python3Packages = pkgs.unstable.python311.pkgs;
      }).overrideAttrs
        (old: {
          # FIXME: https://github.com/NixOS/nixpkgs/issues/321623
          patches = (old.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              url = "https://github.com/mealie-recipes/mealie/commit/445754c5d844ccf098f3678bc4f3cc9642bdaad6.patch";
              hash = "sha256-ZdATmSYxhGSjoyrni+b5b8a30xQPlUeyp3VAc8OBmDY=";
              revert = true;
            })
          ];
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
