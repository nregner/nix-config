{ self, lib, ... }:
{
  imports = [
    ../../../modules/nixos/base/nix.nix
    ../../../modules/nixos/server/services/tailscaled-autoconnect.nix
    ./hardware-configuration.nix
    ./store-image.nix
    ./tailscale.nix
  ];

  networking.hostName = "enceladus-linux-vm";

  users.users = {
    builder.openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
    builder.extraGroups = [ "wheel" ];
    builder.password = "builder";
  };

  # users.users.root.password = lib.mkForce "root";
  # services.openssh.settings.PasswordAuthentication = lib.mkForce false;

  # programs.ssh.extraConfig = ''
  #   Match Address 10.0.2.2
  #     PermitEmptyPasswords yes
  #     PasswordAuthentication no
  #     PubkeyAuthentication no
  # '';

  services.openssh.enable = true;

  # don't rebuild vm image on every commit
  system.nixos.tags = lib.mkForce [ ];
}
