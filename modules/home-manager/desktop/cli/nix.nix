{
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [ inputs.nix-index-database.hmModules.nix-index ];

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    nvd # nix closure diff
  ];

  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/6
  home.activation.report-changes = config.lib.dag.entryAnywhere ''
    ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath || true
  '';
}
