# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ inputs, pkgs }: {
  inherit (inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}) attic;
  route53-ddns = pkgs.unstable.callPackage ./route53-ddns { };
  # jetbrains-toolbox = pkgs.unstable.callPackage ./jetbrains-toolbox.nix { };

  # cross-compile heavy ARM on dependencies on more powerful x86 machines
  # TODO: Something more generic/flexible
  cross = import ./cross.nix {
    inherit inputs;
    localSystem = "x86_64-linux";
    crossSystem = "aarch64-multiplatform";
  };
}
