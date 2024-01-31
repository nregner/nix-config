{ inputs, outputs, pkgs, lib, ... }: {
  imports = [
    #
    ../base
    ./alacritty.nix
    ./cli
    ./jetbrains
    ./nvim
    ./sops.nix
    ./theme.nix
  ];

  # standalone install - reimport nixpkgs
  nixpkgs = import ../../../nixpkgs.nix { inherit inputs outputs; };

  programs.zsh = {
    enable = true;
    shellAliases = lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      open = "xdg-open";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
    };
  };

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}
