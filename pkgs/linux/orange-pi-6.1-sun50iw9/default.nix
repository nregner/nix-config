{ lib, pkgs, linuxManualConfig, fetchFromGitHub, stdenv, ... }@args:
with lib;
linuxManualConfig (rec {
  version = "6.1.31";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = versions.pad 3 version;

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  extraMeta.platforms = [ "aarch64-linux" ];

  # src = fetchgit {
  #   url = "/home/nregner/dev/linux-orangepi/build/source";
  #   ref = "orange-pi-6.1-sun50iw9";
  #   rev = "96760661fbde0ba95f16f8e934226edbc51b9a73";
  # };

  # TODO: Flake input?
  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "linux-orangepi";
    rev = "5ad66f8f01a41a54bcdee90053a7e0f444bca17c"; # orange-pi-6.1-sun50iw9
    sha256 = "sha256-TM/2NETYTSiWXbiTMRSiGlA3RbGnnvuG8RwgXCIOXn8=";
  };

  configfile = ./.config;
  allowImportFromDerivation = true;

  # FIXME: This is an awful, fragile hack that relies the last duplicated flag taking precedence
  extraMakeFlags = [
    "WERROR=0"
    "CC=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "LD=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}ld"
    "CROSS_COMPILE=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}"
  ];

  kernelPatches = [{
    name = "nix-patches";
    patch = let
      patchesPath = ./patches;
      isPatchFile = name: value:
        value == "regular" && (lib.hasSuffix ".patch" name);
      patchFilePath = name: patchesPath + "/${name}";
    in map patchFilePath (lib.naturalSort (lib.attrNames
      (lib.filterAttrs isPatchFile (builtins.readDir patchesPath))));

    extraStructuredConfig = with lib.kernel; { };
  }];
} // (args.argsOverride or { }))
