{ self, pkgs, ... }: {
  imports = [ ./nix.nix ./hydra-builder.nix ];

  environment.systemPackages = with pkgs.unstable; [
    util-linux
    coreutils-full
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  programs.ssh.knownHosts = self.globals.ssh.knownHosts;
}
