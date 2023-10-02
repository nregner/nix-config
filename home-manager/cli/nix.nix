{ inputs, config, pkgs, ... }: {
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
    comma # auto-run from nix-index: https://github.com/nix-community/comma
    nix-output-monitor
    nix-prefetch
    nix-tree
    nixfmt
    nvd # nix closure diff

    # nix-du -s=500MB | xdot -
    nix-du
    xdot
  ];

  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/6
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
  '';
}
