{ pkgs, lib, ... }:
{
  programs.zsh = {
    enable = true;

    syntaxHighlighting = {
      enable = true;
      catppuccin.enable = true;
    };

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
}
