{ config, ... }: {
  networking = {
    hostName = "sagittarius";
    useDHCP = true;
    interfaces.enp4s0.useDHCP = true;
    interfaces.enp5s0.useDHCP = true;
  };

  sops.secrets.ddns.key = "route53/ddns";
  services.route53-ddns = {
    enable = true;
    domain = "nregner.net";
    ipType = "public";
    ttl = 900;
    environmentFile = config.sops.secrets.ddns.path;
  };
}
