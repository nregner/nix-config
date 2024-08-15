{ inputs, pkgs, ... }:
let
  port = 8000;
in
{
  services.harmonia = {
    enable = true;
    package = inputs.harmonia.packages.${pkgs.system}.harmonia;
    settings = {
      bind = "127.0.0.1:${toString port}";
      priority = 99;
    };
  };

  nginx.subdomain.cache = {
    "/".extraConfig = ''
      proxy_pass http://127.0.0.1:${toString port};
      proxy_set_header Host $host;
      proxy_redirect http:// https://;
      proxy_http_version 1.1;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      zstd on;
      zstd_types application/x-nix-archive;

      limit_except GET {
        allow 192.168.0.0/24;
        allow 100.0.0.0/8;
        deny all;
      }
    '';
  };
}
