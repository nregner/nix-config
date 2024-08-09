{ self, lib, ... }:
{
  imports = [ ../../../modules/nixos/base ];

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "enceladus-linux-vm";

  users.users = {
    nregner.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
  };

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
