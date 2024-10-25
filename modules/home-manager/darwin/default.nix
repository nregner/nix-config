{ pkgs, ... }:
{
  imports = [ ./hammerspoon.nix ];

  # prefer these over system utilities for consistency with linux
  home.packages = with pkgs.unstable; [
    util-linux
    coreutils-full
  ];
}
