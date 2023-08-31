# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }:
let inherit (pkgs) callPackage;
in {

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit inputs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}
