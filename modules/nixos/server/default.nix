{ config, lib, ... }:
{
  imports = [
    ../base
    ./services
    ./programs
  ];
  services.tailscaled-autoconnect.enable = lib.mkDefault true;

  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* *:20:00";
    flake = "github:nathanregner/nix-config#${config.networking.hostName}";
    operation = "boot";
    flags = [ "--refresh" ];
    randomizedDelaySec = "5m";
  };
}
