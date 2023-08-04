# Custom packages with explicit cross-compilation
{ nixpkgs, localSystem, crossSystem }:
let
  # pkgs = nixpkgs.legacyPackages.${localSystem};
  pkgs = import nixpkgs {
    system = localSystem;
    # FIXME: hack to bypass "FATAL: Module ahci not found" error
    overlays = [
      (final: prev: {
        makeModulesClosure = x:
          prev.makeModulesClosure (x // { allowMissing = true; });
      })
    ];
  };
  crossPkgs = import nixpkgs { inherit localSystem crossSystem; };

in rec {
  wcnmodem-firmware = crossPkgs.callPackage ./firmware/wcnmodem.nix { };

  u-boot-v2021_07-sunxi = crossPkgs.callPackage ./u-boot/v2021.07-sunxi.nix { };
  u-boot-v2021_10-sunxi = crossPkgs.callPackage ./u-boot/v2021.10-sunxi.nix { };

  linux_orange-pi-5_16-sun50iw9 =
    crossPkgs.callPackage ./linux/orange-pi-5.16-sun50iw9 {
      stdenv = pkgs.stdenv // {
        cc = let gcc = pkgs.callPackage ./gcc/gcc-aarch64-none-linux/9 { };
        in gcc // {
          targetPrefix = "aarch64-none-linux-gnu-";
          bintools = gcc;
        };
      };
    };

  linux_orange-pi-6_1-sun50iw9 =
    crossPkgs.callPackage ./linux/orange-pi-6.1-sun50iw9 {
      stdenv = pkgs.stdenv // {
        cc = let gcc = pkgs.callPackage ./gcc/gcc-aarch64-none-linux/9 { };
        in gcc // {
          targetPrefix = "aarch64-none-linux-gnu-";
          bintools = gcc;
        };
      };
    };
}
