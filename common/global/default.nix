{ lib, pkgs, outputs, ... }: {
  imports = [
    ./boot.nix
    ./networking.nix
    ./sops.nix
    ./system-utilities.nix
    ./tailscale.nix
    ./users.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };

    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "nregner" ];
      substituters = [ "http://sagittarius:8080/default" ];
      trusted-public-keys =
        [ "default:h0V4pJnSGtvqgGKLO3KF0VJ0iOaiVBfa4OjmnnR2ob8=" ];
      auto-optimise-store = true;
    };
  };

}
