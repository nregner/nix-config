{ inputs, outputs, ... }:
{
  imports = [
    ../base
    ./alacritty.nix
    ./cli
    ./jetbrains
    ./nvim
    ./sops.nix
    ./theme.nix
    inputs.nix.homeModules.default
  ];

  # standalone install - reimport nixpkgs
  nixpkgs = import ../../../nixpkgs.nix { inherit outputs; };

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}
