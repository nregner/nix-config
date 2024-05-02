# add a nvfetcher `sources` attribute to all modules inputs
inputs:
({ pkgs, lib, ... }:
  let
    sources = (pkgs.callPackage ../_sources/generated.nix { }) // {
      catppuccin = builtins.mapAttrs (_: p: p.src)
        (pkgs.callPackage "${inputs.catppuccin-nix}/_sources/generated.nix"
          { });
    };
  in { config._module.args = { inherit sources; }; })

