{ inputs, lib, ... }: {
  imports = [ inputs.orangepi-nix.nixosModules.zero2 ];

  hardware.orangepi-zero2 = {
    pkgs = inputs.orangepi-nix.packages.x86_64-linux.pkgsCross;
  };

  # TODO: FIXME
  system.requiredKernelConfig = lib.mkForce [ ];
}
