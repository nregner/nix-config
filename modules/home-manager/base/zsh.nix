{ pkgs, ... }: {

  programs.zsh = {
    enable = true;
    initExtra = ''
      # Auto-start tmux
      if command -v tmux &> /dev/null \
          && [ -n "$PS1" ] \
          && [[ ! "$TERM" =~ screen ]] \
          && [[ ! "$TERM" =~ tmux ]] \
          && [ -z "$TMUX" ] \
          && [[ ! "$TERMINAL_EMULATOR" =~ "JetBrains" ]]; then
        tmux attach -t 0 || tmux new -s 0
      fi

      bindkey -M viins 'jk' vi-cmd-mode

      # https://github.com/nix-community/nix-direnv/wiki/Shell-integration
      flakify() {
        if [ ! -e flake.nix ]; then
          nix flake new -t github:nix-community/nix-direnv .
        elif [ ! -e .envrc ]; then
          echo "use flake" > .envrc
          direnv allow
        fi
        ${"EDITOR"} flake.nix
      }
    '';
    # defaultKeymap = "viins";
    oh-my-zsh = {
      enable = true;
      plugins = [ "aws" "git" "vi-mode" ];
      # theme = "robbyrussell";
    };
    shellAliases = {
      jqless = "jq -C | less -r";

      nr = "nixos-rebuild --flake .";
      nrs = "nixos-rebuild --flake . switch";
      snr = "sudo nixos-rebuild --flake .";
      snrs = "sudo nixos-rebuild --flake . switch";
      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

      npd = "nix profile diff-closures --profile /nix/var/nix/profiles/system";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.unstable.starship;
    settings = {
      # Move directory to the second line
      format = "$all$directory$character";
      aws.disabled = true;
      direnv.disabled = false;
      docker_context.only_with_files = false;
      nix_shell.symbol = "❄️";
      package.disabled = true;
    };
  };
}
