{ inputs, pkgs, ... }: {
  imports = [ inputs.stylix.homeManagerModules.stylix ./alacritty.nix ];

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    # image = "${pkgs.gnome.gnome-backgrounds}/gnome/blobs-d.svg";
    fonts = {
      monospace = {
        # nerdfonts is large - pull in the ones we care about
        package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
        name = "JetBrainsMono Nerd Font";
      };
    };
    autoEnable = false;
  };

  home.packages = with pkgs; [
    # apps
    discord
    easyeffects
    firefox
    gparted

    # tools
    awscli2
    gh
    jq
    pv
    uucp

    # k8s
    kubectl
    kubernetes-helm

    # 3d printer
    unstable.super-slicer
    freecad
  ];

  services.easyeffects.enable = true;
}
