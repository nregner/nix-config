{ inputs, pkgs, lib, ... }: {
  imports = [ inputs.orangepi-nix.nixosModules.zero2 ];
  nixpkgs.overlays = [ inputs.orangepi-nix.overlays.default ];
  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";

  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor
    inputs.orangepi-nix.packages.x86_64-linux.pkgsCross.linux-6_6-rk35xx);
}
