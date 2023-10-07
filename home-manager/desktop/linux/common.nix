{ pkgs, ... }: {
  imports = [ ../default.nix ];

  home.packages = with pkgs; [
    # apps
    discord
    firefox
    gparted

    # tools
    attic
    awscli2
    gh
    jq
    pv
    xclip
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      open = "xdg-open";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
    };
  };
}
