{
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.nix-doom-emacs-unstraightened.hmModule ];

  programs.doom-emacs = {
    enable = true;
    # doomDir = config.lib.file.mkFlakeSymlink "./doom";
    doomDir = ./doom;
    # doomLocalDir = "~/.local/share/nix-doom";
    extraPackages =
      epkgs: with epkgs; [
        tmux-pane
        treesit-grammars.with-all-grammars
      ];
  };

  # services.emacs = {
  #   enable = true;
  #   socketActivation.enable = true;
  # };

  xdg.configFile."emacs2".source = config.lib.file.mkFlakeSymlink ./user;

  # programs.emacs.enable = true;
  #
  # xdg.configFile."doom/config.el".source = ./user/config.el;
  # xdg.configFile."doom/init.el".source = ./doom/init.el;
  # xdg.configFile."doom/packages.el".source = ./doom/packages.el;
}
