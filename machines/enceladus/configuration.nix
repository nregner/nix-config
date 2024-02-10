{ inputs, config, pkgs, ... }@args: {
  imports = [ ./builder.nix ../../modules/darwin ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  nix = {
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      trusted-users = [ "nregner" ];
    };

    linux-builder-2 = {
      enable = true;
      # package = pkgs.darwin.linux-builder;
      maxJobs = 12;
      # comment out for inital setup (pulls vm image via cache.nixos.org)
      # remove /var/lib/darwin-builder/*.img to force a reset
      config = import ./linux-builder.nix args;
    };

    buildMachines = [{
      hostName = "sagittarius";
      protocol = "ssh";
      sshUser = "nregner";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      maxJobs = 10;
      speedFactor = 1;
    }];
  };

  programs.ssh.knownHosts = {
    iapetus.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhre0L0AW87qYkI5Os8U2+DS5yvAOnjpEY+Lmn5f0l7";
    sagittarius.publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIQOaeRY07hRIPpeFYRWoQOzP+toxZjveC5jVHF+vpIj";
  };

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  environment.etc = {
    "nix/flake-channels/system".source = inputs.self;
    "nix/flake-channels/nixpkgs".source = inputs.nixpkgs;
    "nix/flake-channels/nixpkgs-unstable".source = inputs.nixpkgs-unstable;
    "nix/flake-channels/home-manager".source = inputs.home-manager;
  };

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };
  environment.systemPackages = [
    config.services.tailscale.package
    config.nix.linux-builder.package # keep the base image around in case we need to rebuild
  ];
}
