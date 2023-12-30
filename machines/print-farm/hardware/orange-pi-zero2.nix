{ inputs, lib, ... }: {
  imports = [ inputs.orangepi-nix.nixosModules.zero2 ];
  nixpkgs.overlays = [ inputs.orangepi-nix.overlays.default ];
  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
}
