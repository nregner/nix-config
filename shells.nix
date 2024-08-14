{
  inputs,
  inputs',
  pkgs,
  treefmt,
  outputs,
}:
{
  default = pkgs.mkShell {
    packages = with pkgs.unstable; [
      node2nix
      sops
      tenv
      treefmt
    ];
  };

  bootstrap = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs.unstable; [
      nix
      git
    ];
    packages = [ inputs'.home-manager.packages.home-manager ];
  };

  nix-update = pkgs.stdenv.mkDerivation {
    name = "nix-update";
    inherit
      (import "${inputs.nixpkgs}/maintainers/scripts/update.nix" {
        include-overlays = builtins.attrValues outputs.overlays;

        # system = pkgs.system;
        predicate = (
          let
            prefix = pkgs.lib.traceVal "${toString ./.}/pkgs";
            prefixLen = builtins.stringLength prefix;
          in
          (_: p: (builtins.substring 0 prefixLen (inputs.nixpkgs.lib.traceVal p.meta.position)) == prefix)
        );

      })
      shellHook
      ;
  };
}
