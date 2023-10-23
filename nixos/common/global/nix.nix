{ self, inputs, outputs, lib, pkgs, ... }: {
  environment.etc = {
    "nix/flake-channels/system".source = inputs.self;
    "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
    "nix/flake-channels/home-manager".source = inputs.home-manager;
  };

  nixpkgs = import ../../../nixpkgs.nix { inherit inputs outputs; };

  nix = {
    package = lib.mkDefault pkgs.unstable.nix;

    # pin the flake registry to flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) inputs;

    # https://discourse.nixos.org/t/do-flakes-also-set-the-system-channel/19798
    # pin system channels to flake inputs
    nixPath = [
      "nixpkgs=/etc/nix/flake-channels/nixpkgs"
      "home-manager=/etc/nix/flake-channels/home-manager"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "root" "@wheel" ];

      # keep build dependencies for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;

      substituters = [
        "http://sagittarius:8080/default?priority=10"
        "https://cache.nixos.org?priority=9"
      ];

      trusted-public-keys =
        [ "default:h0V4pJnSGtvqgGKLO3KF0VJ0iOaiVBfa4OjmnnR2ob8=" ];
    };
  };

  # keep a reference to the flake source that was used to build
  # https://www.reddit.com/r/NixOS/comments/16t2njf/small_trick_for_people_using_nixos_with_flakes
  environment.etc."nixos/flake".source = self.outPath;
  system.nixos.tags = [ self.sourceInfo.shortRev or "dirty" ];

  # show config changes on switch
  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/33
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
