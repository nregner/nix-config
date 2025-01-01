{ pkgs, ... }:
let
  port = 8083;
in
{
  services.ntfy-sh = {
    enable = true;
    package = pkgs.unstable.ntfy-sh;
    # https://docs.ntfy.sh/config/
    settings = {
      base-url = "https://ntfy.nregner.net";
      behind-proxy = true;
      listen-http = ":${toString port}";
    };
  };

  # https://docs.ntfy.sh/config/?h=proxy#nginxapache2caddy
  nginx.subdomain.ntfy = {
    "/" = {
      proxyPass = "http://127.0.0.1:${toString port}/";
      extraConfig =
        # nginx
        ''
          proxy_set_header Host $http_host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          proxy_connect_timeout 3m;
          proxy_send_timeout 3m;
          proxy_read_timeout 3m;

          client_max_body_size 0; # Stream request body to backend
        '';
    };
  };
}
