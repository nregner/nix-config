{ pkgs, ... }:
let
  port = 8083;
in
{
  services.ntfy-sh = {
    enable = true;
    package = pkgs.unstable.ntfy-sh;
    settings = {
      base-url = "https://ntfy.nregner.net";
      listen-http = ":${toString port}";
    };
  };

  nginx.subdomain.ntfy = {
    "/".proxyPass = "http://127.0.0.1:${toString port}/";
  };
}
