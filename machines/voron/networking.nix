{ config, ... }: {
  networking = {
    hostName = "voron";
    useNetworkd = true;
    interfaces.end1.useDHCP = true;
  };

  sops.secrets.ddns.key = "route53/ddns";
  services.route53-ddns = {
    enable = true;
    domain = "voron.nregner.net";
    ipType = "lan";
    ttl = 60;
    environmentFile = config.sops.secrets.ddns.path;
  };
}
