{ inputs, outputs, lib, pkgs, ... }: {
  imports = [
    ./.
    ./cli
    ./desktop/alacritty.nix
    ./desktop/jetbrains
    ./desktop/theme.nix
    ./dev/sops.nix
    ./nvim
    ../terraform/tailscale
    inputs.mac-app-util.homeManagerModules.default
  ];

  # standalone install - reimport nixpkgs
  nixpkgs = import ../nixpkgs.nix { inherit inputs outputs; };

  programs.alacritty.settings = { font = { size = lib.mkForce 11; }; };

  home = {
    username = "nregner";
    homeDirectory = "/Users/nregner";
    flakePath = "/Users/nregner/nix-config";
    # Use a case-sensitive file system for nix builds
    sessionVariables = { TMPDIR = "/Volumes/tmp"; };
  };

  home.packages = with pkgs.unstable; [
    # tools
    awscli2
    fd
    gh
    jq
    nushell
    pv
    ripgrep
    rsync

    libiconv
    rustup

    nix
    comma # auto-run from nix-index: https://github.com/nix-community/comma
    nix-output-monitor
    nix-prefetch
    nixfmt
    # nix-du # nix-du -s=500MB | xdot -
    pkgs.xdot-darwin

    rectangle
  ];

  programs.zsh = {
    shellAliases = {
      snr = lib.mkForce "sudo darwin-rebuild --flake .";
      snrs = lib.mkForce "sudo darwin-rebuild --flake . switch";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
