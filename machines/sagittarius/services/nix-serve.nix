{ pkgs, ... }:
{
  services.nix-serve = {
    enable = true;
    port = 8000;
    package = pkgs.unstable.nix-serve-ng;
    extraParams = "--priority 99";
  };
}
