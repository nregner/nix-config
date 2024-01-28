{ inputs, pkgs, lib, ... }: {
  imports = [ inputs.orangepi-nix.nixosModules.zero2 ];
  nixpkgs.overlays = [ inputs.orangepi-nix.overlays.default ];
  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";

  # https://unix.stackexchange.com/questions/593573/how-to-turn-off-wireless-power-management-permanently-using-systemd-networkd
  systemd.services.wlan-always-on = {
    description = "Keep wireless device %i from sleeping";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = { ExecStart = "${pkgs.iw}/bin/iw %i set power_save off"; };
  };
}
