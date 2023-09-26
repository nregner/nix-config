{ lib, pkgs, ... }: {
  imports =
    [ ./. ./cli ./desktop/jetbrains.nix ./desktop/linux/gnome.nix ./nvim ];

  home.packages = with pkgs; [
    # apps
    openrgb

    # tools
    uucp

    # k8s
    kubectl
    kubernetes-helm

    # 3d printer
    unstable.super-slicer
    freecad-link
  ];

  programs.alacritty.settings = { font = { size = lib.mkForce 11; }; };

  services.easyeffects.enable = true;

  home = {
    username = "nregner";
    homeDirectory = "/home/nregner";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
