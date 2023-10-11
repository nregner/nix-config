# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }: {
  inherit (inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}) attic;

  gitea-github-mirror = pkgs.unstable.callPackage ./gitea-github-mirror { };

  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };

  netdata-latest = pkgs.unstable.callPackage ./netdata.nix { };

  # jetbrains-toolbox = pkgs.unstable.callPackage ./jetbrains-toolbox.nix { };

  # https://github.com/realthunder/FreeCAD/tree/LinkMerge
  freecad-link = pkgs.unstable.freecad.overrideAttrs (oldAttrs: {
    pname = "${oldAttrs.pname}-link";
    version = inputs.freecad.rev;
    src = inputs.freecad;
  });

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit inputs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}
