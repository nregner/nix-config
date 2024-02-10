{ pkgs, ... }: {
  imports = [ ../base ./nix.nix ];

  users.mutableUsers = true;

  # login shell
  programs.zsh.enable = true;
  users.users.nregner.shell = pkgs.zsh;
}
