{ inputs, pkgs, ... }: {
  imports = [
    inputs.nixos-generators.nixosModules.all-formats
    ./builders.nix
    ./backups.nix
    ./networking.nix
    ./nix.nix
    ./sops.nix
    ./tailscale.nix
    ./users.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # login shell
  programs.zsh.enable = true;
  users.users.nregner.shell = pkgs.zsh;

  # basic system utilities
  environment.systemPackages = with pkgs; [
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
