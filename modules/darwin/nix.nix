{ inputs, outputs, config, lib, pkgs, ... }: {
  imports = [ ../nixos/desktop/nix.nix ];

  nixpkgs = import ../../nixpkgs.nix { inherit inputs outputs; };

  nix = {
    # package = lib.mkDefault pkgs.unstable.nix;

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      user = "root";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "@wheel" ];

      # keep build dependencies for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      substituters = [
        "http://sagittarius:8000?priority=10&trusted=1"
        "https://cache.nixos.org?priority=9"
      ];

      trusted-public-keys =
        [ "default:h0V4pJnSGtvqgGKLO3KF0VJ0iOaiVBfa4OjmnnR2ob8=" ];
    };
  };

  # show config changes on switch
  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/33
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd config.nix.package ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
