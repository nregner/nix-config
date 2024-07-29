{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    initExtra = ''
      export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

      flakify() {
        nix flake new -t github:NixOS/templates#''${1:-"utils-generic"} .
      }

      # https://github.com/NixOS/nixpkgs/issues/275770
      complete -C aws_completer aws
    '';
    # https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#-usage
    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.unstable.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
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
