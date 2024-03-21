# TODO: generate sops.yaml
{ lib }: {
  ssh = rec {
    hostKeys = {
      enceladus =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKs6KBP0vkY+EHrtZvIq9KsWGQ83iet0Enu7AA1nhyAP";
      iapetus =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhre0L0AW87qYkI5Os8U2+DS5yvAOnjpEY+Lmn5f0l7";
      m3-linux-builder-vm =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb ";
      sagittarius =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQOaeRY07hRIPpeFYRWoQOzP+toxZjveC5jVHF+vpIj";
      voron =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbDjUMsVH2t2f+pldWmU23ahMShVIlws1icrn66Jexu";
    };

    userKeys = {
      "nregner@enceladus" =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJN0UxPvRjkqYdq8OFtzO/borc4lU4QNYSJiGhgx3MkI";
    };

    allKeys = hostKeys // userKeys;

    knownHosts = lib.mapAttrs (name: value: { publicKey = value; }) hostKeys;
  };
}
