{
  pkgs,
  inputs,
  sources,
}:
{
  # https://github.com/NixOS/nix/issues/9087
  nix.settings.flake-registry = pkgs.runCommandLocal "flake-registry.json" { } ''
    cp ${sources.flake-registry.src}/flake-registry.json $out
  '';

  nix.registry = {
    nixpkgs.to = {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = inputs.nixpkgs-unstable.rev;
      type = "github";
    };
    nixpkgs-stable.to = {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = inputs.nixpkgs.rev;
      type = "github";
    };
  };
}
