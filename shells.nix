{
  inputs',
  pkgs,
  treefmt,
  agenix-rekey,
}:
{
  default = pkgs.mkShell {
    packages = with pkgs.unstable; [
      age
      agenix-rekey
      node2nix
      sops
      ssh-to-age
      tenv
      treefmt
    ];
  };

  bootstrap = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    nativeBuildInputs = with pkgs.unstable; [
      nixVersions.latest
      git
    ];
    packages = [
      inputs'.home-manager.packages.home-manager
    ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ inputs'.nix-darwin.packages.darwin-rebuild ];
  };
}
