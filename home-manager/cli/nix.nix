{ pkgs, ... }: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    # https://github.com/nix-community/nix-direnv
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    nixfmt

    nix-du
    graphviz
    nix-output-monitor
    nix-prefetch
    nix-tree
  ];
}
