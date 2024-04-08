{ inputs, config, pkgs, lib, ... }: {
  programs.git = {
    enable = true;
    userName = "Nathan Regner";
    userEmail = "nathanregner@gmail.com";
    lfs.enable = true;
    extraConfig = {
      push = { autoSetupRemote = true; };
      diff = {
        # use difftastic as difftool: https://difftastic.wilfred.me.uk/git.html
        tool = lib.mkDefault "difftastic";
        algorithm = "histogram";
      };
      difftool = {
        prompt = false;
        difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
      };
      pager.difftool = true;
      alias = {
        difft = "difftool";
        dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff; }; f";
        # https://github.com/orgs/community/discussions/9632#discussioncomment-4702442
        diff-refactor = ''
          -c color.diff.oldMoved='white dim'
          -c color.diff.oldMovedAlternative='white dim'
          -c color.diff.newMoved='white dim'
          -c color.diff.newMovedAlternative='white dim'
          -c color.diff.newMovedDimmed='white dim'
          -c color.diff.newMovedAlternativeDimmed='white dim'
          diff --ignore-blank-lines --color-moved=dimmed-zebra --color-moved-ws=ignore-all-space --minimal'';
      };
      include = { path = "${config.xdg.configHome}/git/local"; };
      rebase.updateRefs = true;
      pull.rebase = true;
    };
  };

  home.packages = with pkgs.unstable; [ difftastic ];

  programs.lazygit = rec {
    enable = true;
    # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#overriding-default-config-file-location
    package = pkgs.unstable.callPackage
      ({ runCommand, makeWrapper, lazygit, formats, remarshal, jq, ... }:
        let
          yamlFormat = formats.yaml { };
          settingsFile = yamlFormat.generate "lazygit.yaml" settings;
          theme = runCommand "lazygit-theme" {
            nativeBuildInputs = [ jq remarshal ];
          } ''
            remarshal -i "${inputs.catppuccin-lazygit}/themes/mocha/blue.yml" -of json \
              | jq '{"gui": .}' \
              >$out
          '';
        in runCommand "lazygit-wrapper" {
          nativeBuildInputs = [ makeWrapper ];
        } ''
          makeWrapper ${lazygit}/bin/lazygit $out/bin/lazygit \
            --add-flags '--use-config-file="${theme},${settingsFile}"'
        '') { };
    # https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
    settings = {
      gui = { nerdFontsVersion = "3"; };

      keybinding = {
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
