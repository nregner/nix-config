{ lib, ... }:
{
  imports = [
    ../base
    ./services
    ./programs
  ];
  services.tailscaled-autoconnect.enable = lib.mkDefault true;
  system.hydra-auto-upgrade.enable = lib.mkDefault true;
}
