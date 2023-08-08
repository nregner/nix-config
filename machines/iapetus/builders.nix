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
      #      {
      #        hostName = "ec2-aarch64";
      #        protocol = "ssh";
      #        sshUser = "root";
      #        system = "aarch64-linux";
      #        supportedFeatures =
      #          [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
      #        mandatoryFeatures = [ ];
      #      }
      {
        hostName = "voron";
        protocol = "ssh";
        sshUser = "nregner";
        system = "aarch64-linux";
        supportedFeatures =
          [ "nixos-test" "benchmark" "big-parallel" "kvm" "gccarch-armv8-a" ];
        mandatoryFeatures = [ ];
      }
    ];
  };
}
