{
  self,
  inputs,
  outputs,
  sources,
  pkgs,
  lib,
  ...
}:
{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "sagittarius";
      protocol = "ssh-ng";
      sshUser = "nregner";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 10;
      speedFactor = 1;
    }
    {
      hostName = "sagittarius";
      protocol = "ssh-ng";
      sshUser = "nregner";
      system = "x86_64-linux";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      maxJobs = 10;
      speedFactor = 1;
    }
  ];

  nix.linux-builder = {
    enable = true;
    maxJobs = 8;
    # comment out for inital setup (pulls vm image via cache.nixos.org)
    # remove /var/lib/darwin-builder/*.img to force a reset
    package = lib.makeOverridable (
      { modules }:
      let
        inherit (inputs) nixpkgs;
        nixos = nixpkgs.lib.nixosSystem {
          modules =
            [
              "${nixpkgs}/nixos/modules/profiles/nix-builder-vm.nix"
              ./linux-builder/configuration.nix
            ]
            ++ [
              {
                virtualisation = {
                  host = {
                    inherit pkgs;
                  };
                  cores = 8; # TODO: Figure out why this can't be > 8
                  diskSize = lib.mkForce (64 * 1024);
                };
              }
            ];
          specialArgs = {
            inherit
              self
              inputs
              outputs
              sources
              ;
          };
          system = "aarch64-linux";
        };
      in
      nixos.config.system.build.macos-builder-installer
    ) { modules = [ ]; };
  };

  environment.systemPackages = with pkgs.unstable; [
    util-linux
    coreutils-full
    # keep base image around even if not in use
    pkgs.darwin.linux-builder
  ];

  launchd.daemons.linux-builder.serviceConfig = {
    StandardOutPath = "/var/log/darwin-builder.log";
    StandardErrorPath = "/var/log/darwin-builder.log";
  };

  environment.etc."ssh/ssh_config.d/100-linux-builder.conf".text = lib.mkForce ''
    Host enceladus-linux-vm
      User builder
      Hostname localhost
      Port 31022
  '';
}
