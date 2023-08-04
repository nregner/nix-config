{ config, lib, pkgs, ... }: {
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = lib.mkDefault "client";
  };
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
