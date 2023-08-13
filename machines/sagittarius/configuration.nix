{ inputs, config, lib, modulesPath, nixpkgs, pkgs, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    "${modulesPath}/profiles/qemu-guest.nix"
    ../../common/global
  ];

  nixpkgs.hostPlatform = lib.mkForce "x86_64-linux";
  networking.hostName = "sagittarius";

  users.users.root = {
    password = "root"; # ssh password auth disabled, so whatever :)
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
