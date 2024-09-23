{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initExtra = ''
      bindkey -M viins 'jk' vi-cmd-mode

      flakify() {
        nix flake new -t github:NixOS/templates#''${1:-"utils-generic"} .
      }

      # https://github.com/NixOS/nixpkgs/issues/275770
      complete -C aws_completer aws

      showkey() {
        # show the escape codes for the keys pressed until 5 seconds of inactivity
        # https://unix.stackexchange.com/questions/674816/how-can-i-find-out-what-the-escape-codes-my-terminal-are-sending-for-certain-spe
        STTY='raw -echo min 0 time 50' cat -vte
      }
    '';
    # defaultKeymap = "viins";
    oh-my-zsh = {
      enable = true;
      plugins = [ "vi-mode" ];
    };
    shellAliases =
      let
        nixRebuild = if pkgs.stdenv.isDarwin then "darwin-rebuild" else "nixos-rebuild";
        flakeRef = ''"git+file://$(pwd)?submodules=1"'';
      in
      rec {
        jqless = "jq -C | less -r";
        cdiff = "diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L'"; # diff with full context

        nr = "${nixRebuild} --flake ${flakeRef}";
        nrb = "${nr} build";
        snr = if pkgs.stdenv.isDarwin then "sudo ${nr}" else "${nr} --use-remote-sudo";
        snrb = "${snr} boot";
        snrs = "${snr} switch";
        snrt = "${snr} test";

        hm = "home-manager --flake ${flakeRef}";
        hmb = "${hm} build";
        hms = "${hm} switch";

        npd = "nix profile diff-closures --profile /nix/var/nix/profiles/system";
      };
  };
}
