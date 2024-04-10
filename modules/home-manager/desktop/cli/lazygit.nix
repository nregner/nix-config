{ inputs, pkgs, ... }: {
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
