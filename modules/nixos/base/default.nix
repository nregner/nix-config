{ self, inputs, pkgs, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    inputs.catppuccin-nix.nixosModules.catppuccin
    ./backups.nix
    ./hydra-builder.nix
    ./networking.nix
    ./nix.nix
    ./sops.nix
    ./tailscale.nix
    ./users.nix
  ];

  # theme
  catppuccin.flavour = "mocha";

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
  };

  system.nixos.tags = [ self.sourceInfo.shortRev or "dirty" ];

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
