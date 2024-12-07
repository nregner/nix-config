{
  self,
  lib,
  ...
}:
{
  imports = [ ../../../modules/nixos/server ];

  nixpkgs.hostPlatform = "aarch64-linux";

  networking.hostName = "enceladus-linux-vm";

  users.users = {
    nregner.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
  };

  services.tailscaled-autoconnect = {
    enable = true;
    authKeyFile = "/run/secrets/tailscale-auth-key";
  };

  system.hydra-auto-upgrade.enable = false;

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
