{ self, config, pkgs, lib, ... }@args: {
  imports = [ ./builder.nix ../../modules/darwin ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "enceladus";

  nix = {
    distributedBuilds = true;

    linux-builder-2 = {
      enable = true;
      # package = pkgs.darwin.linux-builder;
      maxJobs = 12;
      # comment out for inital setup (pulls vm image via cache.nixos.org)
      # remove /var/lib/darwin-builder/*.img to force a reset
      config = import ./linux-builder.nix args;
    };

    buildMachines = [
      {
        hostName = "sagittarius";
        protocol = "ssh-ng";
        sshUser = "nregner";
        system = "x86_64-linux";
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        maxJobs = 10;
        speedFactor = 1;
      }
      {
        hostName = "iapetus";
        protocol = "ssh-ng";
        sshUser = "nregner";
        system = "x86_64-linux";
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        maxJobs = 12;
        speedFactor = 2;
      }
    ];
  };

  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

  users.users = {
    nregner.openssh.authorizedKeys.keys =
      lib.attrValues self.globals.ssh.allKeys;
  };

  nregner.hydra-builder.enable = true;

  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };
  environment.systemPackages = [
    config.services.tailscale.package
    config.nix.linux-builder.package # keep the base image around in case we need to rebuild
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
