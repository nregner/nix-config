{
  self,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../../modules/darwin
    ./builders.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "enceladus";

  users.users.nregner = {
    # TODO: separate build user
    openssh.authorizedKeys.keys = lib.attrValues self.globals.ssh.allKeys;
  };

  security.pam.enableSudoTouchIdAuth = true;

  services.nregner.hydra-builder.enable = true;

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };

  environment.systemPackages = [
    pkgs.hydra-auto-upgrade
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
