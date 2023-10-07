# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }: {
  inherit (inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}) attic;

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  netdata-latest = pkgs.unstable.callPackage ./netdata.nix { };

  # jetbrains-toolbox = pkgs.unstable.callPackage ./jetbrains-toolbox.nix { };

  # # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  # freecad-link = (pkgs.unstable.freecad.override {
  #   stdenv = pkgs.unstable.ccacheStdenv;
  # }).overrideAttrs (oldAttrs: {
  #   pname = "${oldAttrs.pname}-link";
  #   version = inputs.freecad.rev;
  #   src = inputs.freecad;
  # });

  # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  freecad-link2 = pkgs.unstable.ccacheStdenv.mkDerivation {
    pname = "freecad-link";
    version = inputs.freecad.rev;
    src = inputs.freecad;
  };

  # # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  # freecad-link = ((pkgs.unstable.libsForQt5.callPackage ./freecad.nix {
  #   inputs = { inherit (inputs) freecad; };
  #   boost = pkgs.unstable.python3Packages.boost;
  #   inherit (pkgs.unstable.python3Packages)
  #     gitpython matplotlib pivy ply pycollada pyside2 pyside2-tools python
  #     pyyaml scipy shiboken2;
  #   })(.override { stdenv = pkgs.unstable.ccacheStdenv;
  # }).overrideAttrs( prev: {
  #   nativeBuildInputs = [ ccacheStdenv.cc] ++ prev.nativeBuildInputs;
  # }))

  # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  freecad-link = let inherit (pkgs.unstable) freecad ccacheStdenv;
  in (freecad.override { stdenv = ccacheStdenv; }).overrideAttrs (prev: {
    version = inputs.freecad.rev;
    src = inputs.freecad;
    nativeBuildInputs = [ ccacheStdenv.cc ] ++ prev.nativeBuildInputs;
  });

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit inputs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}

