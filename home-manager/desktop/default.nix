{ pkgs, ... }: {
  imports = [ ];
  home.packages = with pkgs; [
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar

    discord
    easyeffects
    firefox
    gparted
    openrgb

    jetbrains-toolbox
    alacritty

    awscli2
    gh
    transcrypt
    uucp
    pv
    sops
    kubectl
    helm
  ];

  home.file.".vimrc".source = ./vimrc;
  home.file.".ideavimrc".source = ./ideavimrc;

  services.easyeffects.enable = true;

  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  gtk = {
    enable = true;
    # font.name = "Victor Mono SemiBold 12";
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock = "12h";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gtk/settings/file-chooser" = { clock-format = "12h"; };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
        "dash-to-panel@jderose9.github.com"
        "sound-output-device-chooser@kgshank.net"
        "space-bar@luchrioh"
      ];
    };
    "org/gnome/shell" = {
      favorite-apps =
        [ "firefox.desktop" "org.gnome.Nautilus.desktop" "Alacritty.desktop" ];
    };
  };
}

