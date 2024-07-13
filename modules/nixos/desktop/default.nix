{ pkgs, ... }:
{
  imports = [
    ../base
    ./fhs.nix
    ./nix.nix
  ];

  users.mutableUsers = true;

  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
  };
  users.users.nregner.shell = pkgs.zsh; # login shell
}
