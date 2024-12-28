inputs:
{ pkgs, lib, ... }:
{
  config._module.args = {
    sources = (pkgs.callPackage ../_sources/generated.nix { });
  };
}
