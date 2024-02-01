{ lib, pkgs, ... }: {
  imports =
    [ ../../modules/nixos/server ../../modules/nixos/server/home-manager.nix ];

  # remove rm --force $out/bin/{nix-instantiate,nix-build,nix-shell,nix-prefetch*,nix}
  environment.extraSetup = lib.mkForce "";

  virtualisation = {
    cores = 8; # TODO: Figure out why this can't be > 8
    diskSize = lib.mkForce (64 * 1024);

    # sharedDirectories.dev = {
    #   source = "/Users/nregner/dev";
    #   target = "/home/nregner/dev";
    # };

    # don't use sharedDirectories directly - want to use set `security_model=mapped`
    fileSystems = let
      mkSharedDir = tag: share: {
        name = share.target;
        value.device = tag;
        value.fsType = "9p";
        value.neededForBoot = true;
        value.options =
          [ "trans=virtio" "version=9p2000.L" "msize=${toString 16384}" ];
      };
    in lib.mapAttrs' mkSharedDir {
      dev = {
        source = "/Users/nregner/dev";
        target = "/home/nregner/dev";
      };
    };
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

  # TODO: Remove
  nix.settings.substituters = lib.mkForce [ "https://cache.nixos.org" ];
}

