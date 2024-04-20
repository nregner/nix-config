{ lib, ... }: {
  imports = [ ../base ./services ./programs ];
  services.tailscaled-autoconnect.enable = lib.mkDefault true;
  services.nregner.metrics.enable = lib.mkDefault true;
}
