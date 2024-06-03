{ config, pkgs, ... }:
{
  services.nix-serve = {
    enable = true;
    port = 8000;
    package = pkgs.unstable.nix-serve-ng;
    extraParams = "--priority 99";
  };

  nginx.subdomain.cache = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.nix-serve.port}/";
  };
}
