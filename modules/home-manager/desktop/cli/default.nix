{ pkgs, lib, ... }: {
  imports = [
    #
    ./git.nix
    ./k9s.nix
    ./nix.nix
  ];

  programs.zsh = {
    enable = true;
    initExtra = ''
      # Auto-start tmux
      if command -v tmux &> /dev/null \
          && [ -n "$PS1" ] \
          && [[ ! "$TERM" =~ screen ]] \
          && [[ ! "$TERM" =~ tmux ]] \
          && [ -z "$TMUX" ] \
          && [[ ! "$TERMINAL_EMULATOR" =~ "JetBrains" ]]; then
        tmux attach || tmux
      fi
    '';

    shellAliases = lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
      open = "xdg-open";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
    };
  };

  home.packages = with pkgs.unstable; [
    # text manipulation
    gawk
    gnused
    jq
    ripgrep
    parallel

    # filesystem
    fd
    file
    pv
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
  ];
}

