{ lib, ... }:
{
  imports = [
    ../base
    ./services
    ./programs
  ];
  services.prometheus-host-metrics.enable = lib.mkDefault true;
  services.tailscaled-autoconnect.enable = lib.mkDefault true;
  system.hydra-auto-upgrade.enable = lib.mkDefault true;
}
