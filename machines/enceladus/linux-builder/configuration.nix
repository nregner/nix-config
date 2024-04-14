{ self, lib, ... }: {
  imports = [ ../../../modules/nixos/server ];

  networking.hostName = "enceladus-linux-vm";

  # FIXME: Have to manually run /run/current-system/activate to get secrets to show up...
  sops.defaultSopsFile = null;

  users.users = {
    nregner.openssh.authorizedKeys.keys =
      lib.attrValues self.globals.ssh.allKeys;
  };

  services.tailscaled-autoconnect.enable = true;
}

