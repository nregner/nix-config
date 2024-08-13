{
  inputs,
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    inputs.sops-nix.darwinModules.sops
    ../nixos/base/nix.nix
    ../nixos/desktop/nix.nix
    ./hydra-builder.nix
    ./nix.nix
  ];

  environment.systemPackages = with pkgs.unstable; [
    util-linux
    coreutils-full
  ];

  nix.settings = {
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = lib.mkForce false;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Hack to make pam-reattach work
  # until https://github.com/LnL7/nix-darwin/pull/662
  environment.etc."pam.d/sudo_local".text = lib.mkIf config.security.pam.enableSudoTouchIdAuth ''
    # Written by nix-darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so
    auth       sufficient     pam_tid.so
  '';

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true; # required by Spoons/ControlEscape
  };

  programs.ssh.knownHosts = self.globals.ssh.knownHosts;
}
