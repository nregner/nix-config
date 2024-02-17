{ pkgs, ... }: {

  programs.zsh = {
    enable = true;
    initExtra = ''
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
    shellAliases = let
      nixRebuild =
        if pkgs.stdenv.isDarwin then "darwin-rebuild" else "nixos-rebuild";
    in {
      jqless = "jq -C | less -r";

      nr = "${nixRebuild} --flake .";
      nrs = "${nixRebuild} --flake . switch";
      snr = "sudo ${nixRebuild} --flake .";
      snrs = "sudo ${nixRebuild} --flake . switch";

      hm = "home-manager --flake .";
      hms = "home-manager --flake . switch";

      npd = "nix profile diff-closures --profile /nix/var/nix/profiles/system";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Move directory to the second line
      format = "$all$directory$character";
      package.disabled = true;
      aws.disabled = true;
      nix_shell.disabled = true;
      docker_context = { only_with_files = false; };
      custom.direnv = {
        detect_files = [ ".envrc" ];
        when = ''[[ $(direnv status) =~ " Found RC allowed true " ]]'';
        format = "[ direnv](bold blue)";
      };
    };
  };
}
