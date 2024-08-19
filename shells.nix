{
  inputs',
  pkgs,
  treefmt,
}:
{
  default = pkgs.mkShell {
    packages = with pkgs.unstable; [
      age
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
      nix
      git
    ];
    packages = [ inputs'.home-manager.packages.home-manager ];
  };
}
