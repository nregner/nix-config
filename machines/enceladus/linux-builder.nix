{ lib, ... }: {
  imports = [ ../../modules/nixos/server ];

  virtualisation = {
    cores = 8; # TODO: Figure out why this can't be > 8
    diskSize = lib.mkForce (64 * 1024);
  };

  networking.hostName = "m3-linux-builder-vm";
  # FIXME: Have to manually run /run/current-system/activate to get secrets to show up...
  sops.defaultSopsFile = null;

  services.tailscaled-autoconnect = {
    enable = true;
    secret-key = "tailscale/builder_key";
  };

  users.users = {
    nregner.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJN0UxPvRjkqYdq8OFtzO/borc4lU4QNYSJiGhgx3MkI"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhre0L0AW87qYkI5Os8U2+DS5yvAOnjpEY+Lmn5f0l7"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKs6KBP0vkY+EHrtZvIq9KsWGQ83iet0Enu7AA1nhyAP"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQOaeRY07hRIPpeFYRWoQOzP+toxZjveC5jVHF+vpIj"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbDjUMsVH2t2f+pldWmU23ahMShVIlws1icrn66Jexu"
    ];
  };
}

