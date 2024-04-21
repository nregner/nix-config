{ pkgs, ... }: {
  # fix for running JetBrains IDEs outside of Toolbox
  # https://github.com/NixOS/nixpkgs/issues/240444#issuecomment-1977617644
  programs.nix-ld = {
    enable = true;
    libraries =
      pkgs.unstable.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs.unstable;
  };
}
