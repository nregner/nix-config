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
  ];
}
