{ pkgs, ... }:
{
  home.file.".hammerspoon" = {
    source = ./hammerspoon;
    recursive = true;
  };
  home.packages = [ pkgs.hammerspoon ];
}
