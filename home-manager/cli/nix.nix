{ inputs, pkgs, ... }: {
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    # https://github.com/nix-community/nix-direnv
    nix-direnv.enable = true;
  };

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    nixfmt

    # nix-du -s=500MB | xdot -
    nix-du
    xdot
    nix-output-monitor
    nix-prefetch
    nix-tree
  ];
}
