{ self, lib, ... }:
{
  imports = [
    ../../../modules/nixos/base/nix.nix
    ../../../modules/nixos/server/services/tailscaled-autoconnect.nix
    ./hardware-configuration.nix
    ./store-image.nix
    ./tailscale.nix
  ];

  networking.hostName = "enceladus-linux-vm";

  users.users = {
    builder.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
    builder.extraGroups = [ "wheel" ];
    builder.password = "builder";
  };

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
