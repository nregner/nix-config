{ inputs, config, ... }: {
  config = let hostPkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    system.build.diskoImagesNative =
      hostPkgs.callPackage ./make-disk-image.nix {
        pkgs = hostPkgs;
        nixosConfig = { inherit config; };
        inherit (inputs) disko;
      };
  };
}
