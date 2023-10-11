{ pkgs, ... }: {
  # basic system utilities
  environment.systemPackages = with pkgs; [
    git # needed by flakes

    # text manipulation
    gawk
    gnused
    ripgrep
    vim

    # filesystem
    tree
    file
    fd
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
