{ inputs, config, lib, modulesPath, nixpkgs, pkgs, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    ../../common/global
    ./hardware-configuration.nix
  ];

  nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
  networking.hostName = "sagittarius";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";

  users.users.root = {
    password = "root"; # ssh password auth disabled, so whatever :)
  };

  services.k3s.enable = true;
  services.k3s.extraFlags =
    "--disable traefik --flannel-backend=host-gw --container-runtime-endpoint unix:///run/containerd/containerd.sock";
  networking.firewall.allowedTCPPorts = [ 6443 ];
  virtualisation.containerd.enable = true;

  environment.systemPackages = with pkgs; [ k3s ];

  systemd.services.k3s = {
    wants = [ "containerd.service" ];
    after = [ "containerd.service" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
