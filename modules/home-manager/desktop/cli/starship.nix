{
  config,
  lib,
  ...
}:
let
  inherit (config.catppuccin) sources;
  cfg = config.catppuccin.starship;
in
{
  # FIXME: IFD
  # catppuccin.starship.enable = true;
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # https://starship.rs/config
    settings =
      {
        aws.disabled = true;
        nix_shell = {
          symbol = "❄️";
          heuristic = true;
        };
        docker_context.only_with_files = false;
        package.disabled = true;
      }
      // {
        format = lib.mkDefault "$all";
        palette = "catppuccin_${cfg.flavor}";
      }
      // lib.importTOML "${sources.starship.src}/themes/${cfg.flavor}.toml";
  };
}
