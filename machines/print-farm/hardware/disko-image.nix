{ inputs, config, pkgs, lib, ... }@args: {
  options.disko.sdImage.postInstallScript = lib.mkOption {
    # type = lib.types.functionTo lib.types.package;
    type = lib.types.anything;
    description = "Post-install script to run";
    default = null;
  };

  # TODO: also support aarch64-linux
  config = let hostPkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    system.build.diskoImagesNative =
      hostPkgs.callPackage ./make-disk-image.nix {
        pkgs = hostPkgs;
        nixosConfig = args;
        postInstallScript =
          if (config.disko.sdImage.postInstallScript != null) then
            (config.disko.sdImage.postInstallScript { pkgs = hostPkgs; })
          else
            null;
        inherit (inputs) disko;
      };
  };
}
