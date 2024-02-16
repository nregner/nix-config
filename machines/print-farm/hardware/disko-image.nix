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
            (config.disko.sdImage.postInstallScript { inherit pkgs hostPkgs; })
          else
            null;
        inherit (inputs) disko;
      };

    # source: https://github.com/n8henrie/nixos-btrfs-pi
    boot.postBootCommands = with pkgs; ''
      # On the first boot do some maintenance tasks
      set -Eeuf -o pipefail

      if [ -f /nix-path-registration ]; then
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${util-linux}/bin/findmnt -nvo SOURCE /)
        firmwareDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(
          lsblk -npo MAJ:MIN "$rootPart" |
          ${gawk}/bin/awk -F: '{print $2}' |
          tr -d '[:space:]'
        )

        # Resize the root partition and the filesystem to fit the disk
        echo ',+,' | sfdisk -N"$partNum" --no-reread "$firmwareDevice"
        ${parted}/bin/partprobe
        ${btrfs-progs}/bin/btrfs filesystem resize max /

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}
