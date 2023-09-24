{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Nathan Regner";
    userEmail = "nathanregner@gmail.com";
    lfs.enable = true;
    difftastic.enable = true;
    extraConfig = { push = { autoSetupRemote = true; }; };
  };

  programs.lazygit = {
    enable = true;
    # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
    settings = {
      keybinding = {
        gui = { nerdFontsVersion = "3"; };
        universal = {
          quit = "<c-c>";
          return = "q";
        };
        files = {
          # always commit with EDITOR (also prevents us from getting stuck thanks to "q" remap)
          commitChanges = "";
          commitChangesWithEditor = "c";
        };
        commits = {
          # fix conflicts with tmux
          moveDownCommit = "<c-N>";
          moveUpCommit = "<c-P>";
        };
      };
    };
  };
}
