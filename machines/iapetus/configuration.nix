{ config, lib, pkgs, ... }: {
  imports =
    [ ../../modules/nixos/desktop ./hardware-configuration.nix ./windows-vm ];

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems =
    lib.mkForce [ "vfat" "fat32" "exfat" "ext4" "btrfs" "ntfs" ];

  # networking
  networking.hostName = "iapetus";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  # desktop environment
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome.enable = true;

    layout = "us";
    xkbVariant = "";
  };

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "nregner";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  programs.dconf.enable = true;

  time.timeZone = "America/Boise";
  i18n.defaultLocale = "en_US.UTF-8";

  # sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # Misc
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  zramSwap.enable = true;

  # https://nixos.wiki/wiki/CCache#Derivation_CCache_2
  # man tmpfiles.d
  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  systemd.tmpfiles.rules =
    [ "d ${config.programs.ccache.cacheDir} 0770 root nixbld" ]
    ++ (let cfg = config.services.github-runners.nix-config;
    in [ "d '${cfg.workDir}' 0777 - - - -" ]);

  environment.systemPackages = [
    config.boot.kernelPackages.perf
    pkgs.virt-manager
    pkgs.gnome.nautilus-python
    pkgs.insync-nautilus
  ];

  # Adds to `environment.pathsToLink` the path: `/share/nautilus-python/extensions`
  # needed for nautilus Python extensions to work.
  services.gnome.core-utilities.enable = true;

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.docker = {
    enable = true;
    package = pkgs.unstable.docker_24;
    # enableOnBoot = false; # lazy start with docker.socket
    # extraOptions = "--insecure-registry sagittarius:5000";
    daemon.settings = {
      insecure-registries =
        [ "http://sagittarius:5000" "http://100.92.148.118:5000" ];
    };
    storageDriver = "btrfs";
  };

  # virtualisation.docker.rootless = {
  #   enable = true;
  #   setSocketVariable = true;
  #   # enableOnBoot = false; # lazy start with docker.socket
  #   daemon.settings = { insecure-registries = [ "sagittarius:5000" ]; };
  # };

  services.printing.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 1; # no swap, let it get pretty full...
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # https://docs.github.com/en/rest/actions/self-hosted-runners#create-a-registration-token-for-a-repository
  sops.secrets.github-runner-token = {
    sopsFile = ../../modules/nixos/server/secrets.yaml;
    key = "github_runner_token";
  };
  services.github-runners.nix-config = {
    enable = true;
    name = "iapetus";
    url = "https://github.com/nathanregner/nix-config";
    tokenFile = config.sops.secrets.github-runner-token.path;
    replace = true;
    workDir = "/tmp/nix-config";
    user = "github";
  };
  nix.settings.trusted-users = [ "github" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
