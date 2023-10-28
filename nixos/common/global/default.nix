{ inputs, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    ./boot.nix
    ./networking.nix
    ./nix.nix
    ./sops.nix
    ./system-utilities.nix
    ./tailscale.nix
    ./users.nix
  ];
}
