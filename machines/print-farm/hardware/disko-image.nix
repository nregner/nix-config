{ inputs, config, lib, ... }: {
  options.disko.sdImage.postInstallScript = lib.mkOption {
    # type = lib.types.functionTo lib.types.anything;
    type = lib.types.anything;
    description = "Post-install script to run";
    default = null;
  };

  config = let hostPkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    system.build.diskoImagesNative =
      hostPkgs.callPackage ./make-disk-image.nix {
        pkgs = hostPkgs;
        nixosConfig = { inherit config; };
        postInstallScript =
          if (config.disko.sdImage.postInstallScript != null) then
            lib.getExe
            (hostPkgs.callPackage config.disko.sdImage.postInstallScript { })
          else
            null;
        inherit (inputs) disko;
      };
  };
}
