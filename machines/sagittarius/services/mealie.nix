{ config, pkgs, ... }:
let
  dataDir = "/var/lib/mealie";
in
{
  services.mealie = {
    enable = true;
    # FIXME: https://github.com/NixOS/nixpkgs/issues/325120
    package = pkgs.unstable.mealie.override {
      python3Packages =
        let
          packageOverrides = self: super: {
            extruct = super.extruct.overrideAttrs rec {
              version = "0.17.0";
              src = pkgs.fetchFromGitHub {
                owner = "scrapinghub";
                repo = "extruct";
                rev = "refs/tags/v${version}";
                hash = "sha256-CfhIqbhrZkJ232grhHxrmj4H1/Bq33ZXe8kovSOWSK0=";
              };
            };
          };
          self = pkgs.unstable.python311.override { inherit packageOverrides self; };
        in
        self.pkgs;
    };
  };

  nginx.subdomain.mealie = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}/";
  };

  services.nregner.backups.mealie = {
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
