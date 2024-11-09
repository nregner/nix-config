{ config, pkgs, ... }:
{
  services.qbittorrent = {
    enable = true;
    package = pkgs.unstable.qbittorrent;
    port = 8081;
    openFirewall = false;
    settings = {
      Preferences = {
        "WebUI\\AuthSubnetWhitelist" = "100.0.0.0/8";
        "WebUI\\AuthSubnetWhitelistEnabled" = "true";
        "WebUI\\UseUPnP" = "false";
      };
    };
  };

  nginx.subdomain.qb = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.qbittorrent.port}/";
  };

  users.users.nregner.extraGroups = [ config.services.qbittorrent.group ];
}
