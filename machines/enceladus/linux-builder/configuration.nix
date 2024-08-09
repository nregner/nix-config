{ self, lib, ... }:
{
  imports = [ ../../../modules/nixos/base/nix.nix ];

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "enceladus-linux-vm";

  # FIXME: Have to manually run /run/current-system/activate to get secrets to show up...
  sops.defaultSopsFile = null;

  users.users = {
    builder.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
  };

  system.hydra-auto-upgrade.enable = false;

  services.openssh.enable = true;

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
