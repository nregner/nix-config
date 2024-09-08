{ lib, ... }:
{
  imports = [
    ../base
    ./services
    ./programs
  ];
  services.tailscaled-autoconnect.enable = lib.mkDefault true;
  system.hydraAutoUpgrade.enable = lib.mkDefault true;
}
