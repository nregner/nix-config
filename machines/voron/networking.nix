{ config, ... }: {
  networking.hostName = "voron";

  systemd.network = {
    enable = true;
    networks = {
      "10-eth0" = {
        matchConfig.Name = "end1";
        networkConfig = { DHCP = "yes"; };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  sops.secrets.ddns = {
    sopsFile = ./secrets/ddns.env;
    format = "dotenv";
  };
  services.route53-ddns = {
    enable = true;
    domain = "voron.nregner.net";
    ipType = "lan";
    ttl = 60;
    environmentFile = config.sops.secrets.ddns.path;
  };
}
