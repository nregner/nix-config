{ lib, pkgs, linuxManualConfig, fetchFromGitHub, stdenv, ... }@args:
with lib;
linuxManualConfig (rec {
  version = "5.16.17";

  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  modDirVersion = versions.pad 3 version;

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  extraMeta.platforms = [ "aarch64-linux" ];

  /* src = fetchGit {
       # url = "/home/nregner/dev/linux/orange-pi-5.16-sunxi64";
       url = "https://github.com/nathanregner/linux";
       # ref = "8388f3c89466639b5fedc2e72c677db5e8f1c9f6";
       rev = "8388f3c89466639b5fedc2e72c677db5e8f1c9f6";
     };
  */

  # TODO: Flake input?
  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "linux-orangepi";
    rev = "1a0c42b13943554360e309db7ac8d45879df004d"; # orange-pi-5.16-sunxi64
    sha256 = "sha256-x8OIUqBU91s7WUqZw03gTDKHutQaRRjYVRe0oGDpDms=";
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
