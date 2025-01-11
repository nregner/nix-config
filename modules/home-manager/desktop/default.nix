{
  imports = [
    ../../portable/nix.nix
    ../base
    ./alacritty.nix
    ./cli
    ./jetbrains
    ./nvfetcher.nix
    ./nvim
    ./sops.nix
    ./theme.nix
  ];

  # Allow home-manager to manage itself
  programs.home-manager.enable = true;
}
