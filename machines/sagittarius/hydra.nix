# sudo su hydra
# hydra-create-user nregner --full-name "Nathan Regner" --email-address nathanregner@gmail.com --password-prompt --role admin

{ config, lib, pkgs, ... }: {
  nix.buildMachines = lib.mkForce [
    {
      hostName = "iapetus";
      protocol = "ssh";
      sshUser = "nregner";
      system = "x86_64-linux";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      maxJobs = 12;
      speedFactor = 2;
    }
    {
      hostName = "m3-linux-builder-vm";
      protocol = "ssh";
      sshUser = "nregner";
      system = "aarch64-linux";
      supportedFeatures =
        [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
      mandatoryFeatures = [ ];
      maxJobs = 8;
    }
    {
      hostName = "enceladus";
      protocol = "ssh";
      sshUser = "nregner";
      system = "aarch64-darwin";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
      mandatoryFeatures = [ ];
      maxJobs = 12;
    }
  ];

  services.hydra = {
    enable = true;
    package = pkgs.unstable.hydra_unstable;
    hydraURL = "https://hydra.nregner.net";
    notificationSender = "hydra@nregner.net";
    useSubstitutes = true;
    port = 3001;
    buildMachinesFiles = [
      # TODO: remove
      "/etc/nix/machines"
      # "/etc/nix/hydra-machines"
    ];
  };

  # FIXME
  nix.package = pkgs.nixVersions.nix_2_19;
  nix.extraOptions = let urls = [ "https:" "github:" ];
  in ''
    extra-allowed-uris = ${lib.concatStringsSep " " urls}
  '';

  nginx.subdomain.hydra = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}/";
  };
}
