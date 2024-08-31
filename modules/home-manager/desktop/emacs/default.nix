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
    extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
  };

  services.emacs = {
    enable = true;
    socketActivation.enable = true;
  };

  xdg.configFile."emacs2".source = config.lib.file.mkFlakeSymlink ./user;
}
