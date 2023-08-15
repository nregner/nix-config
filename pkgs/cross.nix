# Custom packages with explicit cross-compilation
{ nixpkgs, nixpkgs-unstable, localSystem, crossSystem }:
let
  hostPkgs = nixpkgs.legacyPackages.${localSystem} // {
    unstable = nixpkgs-unstable.legacyPackages.${localSystem};
  };
  targetPkgs = hostPkgs.pkgsCross.${crossSystem} // {
    unstable = hostPkgs.unstable.pkgsCross.${crossSystem};
  };
  inherit (targetPkgs) callPackage;
in rec {

  # Orange Pi Zero 2
  wcnmodem-firmware = callPackage ./firmware/wcnmodem.nix { };
  u-boot-v2021_10-sunxi = callPackage ./u-boot/v2021.10-sunxi.nix { };
  linux_orange-pi-6_1-sun50iw9 = callPackage ./linux/orange-pi-6.1-sun50iw9 {
    stdenv = targetPkgs.stdenv // {
      cc = let gcc = hostPkgs.callPackage ./gcc/gcc-aarch64-none-linux/9 { };
      in gcc // {
        targetPrefix = "aarch64-none-linux-gnu-";
        bintools = gcc;
      };
    };
  };

  # TODO: More generic way to cross-compile heavy packages
  inherit (targetPkgs.unstable) klipper moonraker;
}
