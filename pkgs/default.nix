# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ nixpkgs, nixpkgs-unstable, pkgs }: {

  klipper-firmware = pkgs.callPackage ./klipper-firmware.nix { };

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit nixpkgs nixpkgs-unstable;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}
