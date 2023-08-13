{
  programs.git = {
    enable = true;
    userName = "Nathan Regner";
    userEmail = "nathanregner@gmail.com";
    lfs.enable = true;
    difftastic.enable = true;
    extraConfig = { push = { autoSetupRemote = true; }; };
  };
  programs.lazygit.enable = true;
}
