{ config, lib, pkgs, ... }: {
  xdg.configFile."tmux/user.conf".source =
    config.lib.file.mkFlakeSymlink ./tmux.conf;

  programs.tmux = {
    enable = true;
    extraConfig = ''
      unbind r
      bind-key r source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message "tmux.conf reloaded"

      ${let colors = config.lib.stylix.colors;
      in lib.concatStrings (map (i: ''
        BASE0${i}='#${colors.${"base0${i}-hex"}}'
      '') [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ])}

      source-file ${config.xdg.configHome}/tmux/user.conf
    '';
    plugins = with pkgs.unstable.tmuxPlugins; [ resurrect yank ];
  };
}
