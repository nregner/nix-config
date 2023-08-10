{ inputs, config, lib, pkgs, ... }: {
  imports = [ ../../common/global ./hardware-configuration.nix ./builders.nix ];

  # Login shell
  programs.zsh.enable = true;
  users.users.nregner.shell = pkgs.zsh;

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems =
    lib.mkForce [ "vfat" "fat32" "exfat" "ext4" "btrfs" ];

  # Networking
  networking.hostName = "iapetus";
  networking.networkmanager.enable = true;

  # Desktop environment
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

  # Sound
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
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.ccache.enable = true;
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];

  virtualisation.docker = {
    enable = true;
    extraOptions = "--insecure-registry nregner.net:32000";
  };

  services.printing.enable = true;

  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
