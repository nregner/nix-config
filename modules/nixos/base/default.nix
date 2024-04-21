{ self, inputs, pkgs, lib, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    inputs.catppuccin-nix.nixosModules.catppuccin
    ./services
    ./networking.nix
    ./nix.nix
    ./sops.nix
    ./tailscale.nix
    ./users.nix
  ];

  time.timeZone = "America/Boise";
  i18n.defaultLocale = "en_US.UTF-8";

  # theme
  catppuccin.flavour = "mocha";

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
  };

  system.nixos.tags = let src = self.sourceInfo;
  in [
    "${src.shortRev or src.dirtyShortRev}-${
      (lib.concatStringsSep "-"
        (builtins.match "([[:digit:]]{4})([[:digit:]]{2})([[:digit:]]{2}).*"
          (src.lastModifiedDate or "")))
    }"
  ];

  boot.tmp.cleanOnBoot = true;

  # basic system utilities
  environment.systemPackages = with pkgs.unstable; [
    git # needed by flakes

    # text manipulation
    gawk
    gnused
    ripgrep
    vim

    # filesystem
    fd
    file
    rsync
    tree
    which

    # archive formats
    gnutar
    unzip
    xz
    zip
    zstd

    # system monitoring
    htop-vim
    iftop
    iotop
    lm_sensors # for `sensors` command
    nmon

    # networking
    curl
    dig
    ethtool
    iputils
    mtr
    nmap
    socat
    tcpdump
    wget

    # debugging
    strace
    ltrace
    lsof
  ];
}
