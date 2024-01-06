{
  nix = {
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      trusted-users = [ "nregner" ];
    };

    # 1. manually `sudo ssh` first
    # 2. ensure `sshUser` is in `trusted-users`
    buildMachines = [
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
        hostName = "m3-linux-builder";
        protocol = "ssh";
        sshUser = "nregner";
        system = "aarch64-linux";
        supportedFeatures =
          [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
        mandatoryFeatures = [ ];
        maxJobs = 8;
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Host m3-linux-builder
      ProxyCommand ssh -W localhost:31022 nregner@nathans-macbook-pro
      User nregner
      IdentityFile /etc/ssh/ssh_host_ed25519_key
  '';
}
