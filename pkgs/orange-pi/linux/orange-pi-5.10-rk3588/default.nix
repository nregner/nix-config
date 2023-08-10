{ inputs, lib, pkgsBuildBuild, linuxManualConfig, ... }@args:
let
  inherit (pkgsBuildBuild) ccache llvmPackages;
  inherit (llvmPackages) bintools-unwrapped clang;
in with lib;
(linuxManualConfig rec {
  version = "5.10.110";
  modDirVersion = version;
  extraMeta = {
    branch = versions.majorMinor version;
    platforms = [ "aarch64-linux" ];
  };

  src = inputs.linux-orange-pi-5-10-rk3588;

  #  src = fetchGit {
  #    url = "/home/nregner/dev/linux-orangepi/orange-pi-5.10-rk3588";
  #    rev = "b9a65c2c9f24b423dc8efff7ae3842c4bc3d021b";
  #  };

  allowImportFromDerivation = true;
  configfile = ./.config;

  # build with Clang for easier cross-compilation
  extraMakeFlags = [
    "LLVM=1"
    "KCFLAGS=-I${clang}/resource-root/include"
    "CC='ccache clang'"
    "CROSS_COMPILE=aarch64-linux-gnu-"
  ];
} // (args.argsOverride or { })).overrideAttrs (final: prev: {
  name = "k"; # stay under u-boot path length limit

  nativeBuildInputs = prev.nativeBuildInputs
    ++ [ bintools-unwrapped clang ccache ];

  # remove CC=stdenv.cc
  makeFlags = filter (flag: !(strings.hasPrefix "CC=" flag)) prev.makeFlags;
})
