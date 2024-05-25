{ pkgs }:
{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt-rfc-style = {
      enable = true;
      package = pkgs.unstable.nixfmt-rfc-style;
    };
    rustfmt.enable = true;
    taplo.enable = true;
  };
}
