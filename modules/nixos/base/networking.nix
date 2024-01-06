{ lib, ... }: {
  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  programs.ssh.knownHosts = {
    iapetus.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhre0L0AW87qYkI5Os8U2+DS5yvAOnjpEY+Lmn5f0l7";
    m3-linux-builder.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJBWcxb/Blaqt1auOtE+F8QUWrUotiC5qBJ+UuEWdVCb";
    nathans-macbook-pro.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKs6KBP0vkY+EHrtZvIq9KsWGQ83iet0Enu7AA1nhyAP";
    sagittarius.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQOaeRY07hRIPpeFYRWoQOzP+toxZjveC5jVHF+vpIj";
    voron.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbDjUMsVH2t2f+pldWmU23ahMShVIlws1icrn66Jexu";
  };
}
