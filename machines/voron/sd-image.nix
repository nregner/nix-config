# This module creates a bootable SD card image containing the given NixOS
# configuration. The generated image is MBR partitioned, with a FAT
# /boot/firmware partition, and ext4 root partition. The generated image
# is sized to fit its contents, and a boot script automatically resizes
# the root partition to fit the device on the first boot.
#
# The firmware partition is built with expectation to hold the Raspberry
# Pi firmware and bootloader, and be removed and replaced with a firmware
# build for the target SoC for other board families.
#
# The derivation for the SD image will be placed in
# config.system.build.sdImage

{ config, lib, pkgs, nixpkgs, ... }:

with lib;

let
  bootfsImage = pkgs.callPackage "${nixpkgs}/nixos/lib/make-ext4-fs.nix" ({
    inherit (config.sdImage) storePaths;
    compressImage = true;
    populateImageCommands = config.sdImage.populateRootCommands;
    volumeLabel = "NIXOS_SD";
  } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
    uuid = config.sdImage.rootPartitionUUID;
  });

  rootfsImage = pkgs.callPackage "${nixpkgs}/nixos/lib/make-ext4-fs.nix" ({
    inherit (config.sdImage) storePaths;
    compressImage = true;
    populateImageCommands = config.sdImage.populateRootCommands;
    volumeLabel = "NIXOS_SD";
  } // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
    uuid = config.sdImage.rootPartitionUUID;
  });

  compressedImageExtension = with config.sdImage;
    if compressImage then
      (if compressImageMethod == "zstd" then
        ".zst"
      else
        ".${compressImageMethod}")
    else
      "";

  compressLevelCmdLineArg = with config.sdImage;
    lib.optionalString (compressImageLevel != null)
    "-${toString compressImageLevel}";
in {
  options.sdImage = {
    imageName = mkOption {
      default =
        "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.img";
      description = ''
        Name of the generated image file.
      '';
    };

    imageBaseName = mkOption {
      default = "nixos-sd-image";
      description = ''
        Prefix of the name of the generated image file.
      '';
    };

    storePaths = mkOption {
      type = with types; listOf package;
      example = literalExpression "[ pkgs.stdenv ]";
      description = ''
        Derivations to be included in the Nix store in the generated SD image.
      '';
    };

    ubootPackage = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = ''
        U-Boot package to use bootloader binary from.
      '';
    };

    ubootBinary = mkOption {
      type = types.str;
      default = "u-boot-*.bin";
      example = "u-boot-sunxi-with-spl.bin";
      description = ''
        U-Boot binary image name or pattern.
      '';
    };

    ubootOffset = mkOption {
      type = types.ints.unsigned;
      default = 8;
      description = ''
        U-Boot binary offset in kibibytes (1024 bytes).
      '';
    };

    partitionsOffset = mkOption {
      type = types.ints.unsigned;
      default = 8;
      description = ''
        Gap in front of the partitions, in mebibytes (1024×1024 bytes).
        Can be increased to make more space for boards requiring to dd u-boot
        SPL before actual partitions.

        Unless you are building your own images pre-configured with an
        installed U-Boot, you can instead opt to delete the existing `FIRMWARE`
        partition, which is used **only** for the Raspberry Pi family of
        hardware.
      '';
    };

    rootPartitionUUID = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
      description = ''
        UUID for the filesystem on the main NixOS partition on the SD card.
      '';
    };

    populateRootCommands = mkOption {
      example = literalExpression
        "''\${config.boot.loader.generic-extlinux-compatible.populateCmd} -c \${config.system.build.toplevel} -d ./files/boot''";
      description = ''
        Shell commands to populate the ./files directory.
        All files in that directory are copied to the
        root (/) partition on the SD image. Use this to
        populate the ./files/boot (/boot) directory.
      '';
    };

    postBuildCommands = mkOption {
      example = literalExpression
        "'' dd if=\${pkgs.myBootLoader}/SPL of=$img bs=1024 seek=1 conv=notrunc ''";
      default = "";
      description = ''
        Shell commands to run after the image is built.
        Can be used for boards requiring to dd u-boot SPL before actual partitions.
      '';
    };

    compressImage = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether the SD image should be compressed using
        <command>zstd</command> or <command>xz</command>.
      '';
    };

    compressImageMethod = mkOption {
      type = types.strMatching "^zstd|xz|lzma$";
      default = "zstd";
      description = ''
        The program which will be used to compress SD image.
      '';
    };

    compressImageLevel = mkOption {
      type = types.nullOr (types.ints.between 0 9);
      default = null;
      description = ''
        Image compression level to override default.
      '';
    };

    expandOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to configure the sd image to expand it's partition on boot.
      '';
    };
  };

  config = {
    # make sure we have an option to login via command line
    users.users.root.password = "root";

    fileSystems = {
      "/boot" = {
        fsType = "vfat";
        # Alternatively, this could be removed from the configuration.
        # The filesystem is not needed at runtime, it could be treated
        # as an opaque blob instead of a discrete FAT32 filesystem.
        options = [ "nofail" "noauto" ];
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };

    sdImage.storePaths = [ config.system.build.toplevel ];

    system.build.sdImage = pkgs.callPackage ({ stdenv, dosfstools, e2fsprogs
      , mtools, libfaketime, util-linux, zstd, xz }:
      stdenv.mkDerivation {
        name = config.sdImage.imageName;

        nativeBuildInputs =
          [ dosfstools e2fsprogs mtools libfaketime util-linux zstd xz ];

        buildInputs = lib.optional (config.sdImage.ubootPackage != null)
          config.sdImage.ubootPackage;

        buildCommand = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}

          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          echo "file sd-image $img${compressedImageExtension}" >> $out/nix-support/hydra-build-products

          echo "Decompressing rootfs image"
          zstd -d --no-progress "${rootfsImage}" -o ./root-fs.img

          blockSize=512
          partitionsOffsetBlocks=$((${
            toString config.sdImage.partitionsOffset
          } * 1024 * 1024 / blockSize))

          rootPartitionOffsetBytes=$((rootPartitionOffsetBlocks * blockSize))

          # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
          rootPartitionSizeBlocks=$(du -B $blockSize --apparent-size ./root-fs.img | awk '{ print $1 }')
          rootPartitionSizeBytes=$((rootPartitionSizeBlocks * blockSize))

          imageSizeBytes=$((rootPartitionOffsetBytes + rootPartitionSizeBytes))
          truncate -s $imageSizeBytes $img

          # Copy the rootfs into the SD image
          eval $(partx $img -o START,SECTORS --nr $rootPartitionNumber --pairs)
          echo "Root partition: $START,$SECTORS"
          dd conv=notrunc if=./root-fs.img of=$img seek=$START count=$SECTORS

          ${lib.optionalString (config.sdImage.ubootPackage != null) ''
            # Install U-Boot binary image
            echo "Install U-Boot: ${config.sdImage.ubootPackage}/${config.sdImage.ubootBinary} ${
              toString config.sdImage.ubootOffset
            }"
            dd if=${config.sdImage.ubootPackage}/${config.sdImage.ubootBinary} of=$img bs=1024 seek=${
              toString config.sdImage.ubootOffset
            } conv=notrunc
          ''}

          ${config.sdImage.postBuildCommands}

          ${lib.optionalString config.sdImage.compressImage
          (if config.sdImage.compressImageMethod == "zstd" then ''
            zstd -T$NIX_BUILD_CORES ${compressLevelCmdLineArg} --rm $img
          '' else ''
            xz -T$NIX_BUILD_CORES -F${config.sdImage.compressImageMethod} ${compressLevelCmdLineArg} $img
          '')}
        '';
      }) { };

    boot.postBootCommands = lib.mkIf config.sdImage.expandOnBoot ''
      # On the first boot do some maintenance tasks
      if [ -f /nix-path-registration ]; then
        set -euo pipefail
        set -x
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}
