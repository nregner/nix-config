{ self, lib, ... }: {
  imports = [ ../../modules/nixos/server ];

  virtualisation = {
    cores = 8; # TODO: Figure out why this can't be > 8
    diskSize = lib.mkForce (64 * 1024);
  };

  networking.hostName = "enceladus-linux-vm";
  # FIXME: Have to manually run /run/current-system/activate to get secrets to show up...
  sops.defaultSopsFile = null;

  services.tailscaled-autoconnect = {
    enable = true;
    secret-key = "tailscale/builder_key";
  };

  users.users = {
    nregner.openssh.authorizedKeys.keys =
      lib.attrValues self.globals.ssh.allKeys;
  };
}

