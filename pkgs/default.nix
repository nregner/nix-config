# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ nixpkgs, pkgs }: {
  inherit (pkgs) ubootOrangePiZero2;

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit nixpkgs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-linux";
  };
}
