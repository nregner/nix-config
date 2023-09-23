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

  services.easyeffects.enable = true;

  home.packages = with pkgs.unstable; [
    # apps
    discord
    firefox
    gparted
    insync

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
    super-slicer
    freecad
  ];
}
