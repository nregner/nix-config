{ inputs, lib, pkgs, ... }: {
  imports = [
    ../common/global/nixpkgs.nix # standalone install - reimport nixpkgs
    ./.
    ./cli
    ./desktop/jetbrains.nix
    ./desktop/linux/hyprland.nix
    ./nvim
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    # apps
    openrgb

    # tools
    screen

    # k8s
    kubectl
    kubernetes-helm

    # 3d printer
    unstable.super-slicer-latest
    freecad-link
  ];

  programs.alacritty.settings = { font = { size = lib.mkForce 11; }; };

  services.easyeffects.enable = true;

  home = {
    username = "nregner";
    homeDirectory = "/home/nregner";
    flakePath = "/home/nregner/nix-config/iapetus";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
