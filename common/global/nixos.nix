{ self, lib, pkgs, inputs, outputs, ... }:
let
  inherit (inputs) nixpkgs-unstable;
  base = "/etc/nixpkgs/channels";
  nixpkgsPath = "${base}/nixpkgs";
in {
  nix = {
    package = lib.mkDefault pkgs.unstable.nix;

    # pin system channel to flake input
    # https://discourse.nixos.org/t/do-flakes-also-set-the-system-channel/19798
    registry.nixpkgs.flake = nixpkgs-unstable; # `nixpkgs#`
    nixPath = [ "nixpkgs=${nixpkgsPath}" ]; # `<nixpkgs>`

    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "nregner" ];
      substituters = [ "http://sagittarius:8080/default" ];
      trusted-public-keys =
        [ "default:h0V4pJnSGtvqgGKLO3KF0VJ0iOaiVBfa4OjmnnR2ob8=" ];
      auto-optimise-store = true;
    };
  };

  systemd.tmpfiles.rules =
    [ "L+ ${nixpkgsPath}     - - - - ${nixpkgs-unstable}" ];

  # https://www.reddit.com/r/NixOS/comments/16t2njf/small_trick_for_people_using_nixos_with_flakes
  environment.etc."nixos-flake".source = ../..;
  system.nixos.tags = [ self.sourceInfo.shortRev or "dirty" ];

  # https://discourse.nixos.org/t/nvd-simple-nix-nixos-version-diff-tool/12397/33
  system.activationScripts.report-changes = ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nvd pkgs.nix ]}
    nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
  '';
}
