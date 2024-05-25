# add a nvfetcher `sources` attribute to all modules inputs
inputs:
(
  { pkgs, lib, ... }:
  let
    sources = (pkgs.callPackage ../_sources/generated.nix { }) // {
      catppuccin = import "${inputs.catppuccin-nix}/.sources";
    };
  in
  {
    config._module.args = {
      inherit sources;
    };
  }
)
