{ self, lib, ... }:
{
  imports = [
    ../../../modules/nixos/base/nix.nix
    ./hardware-configuration.nix
    ./store-image.nix
  ];

  networking.hostName = "enceladus-linux-vm";

  users.users = {
    builder.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
  };

  services.openssh.enable = true;

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
