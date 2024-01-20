{ inputs, lib, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    # ../../modules/nixos/disko-sd-image.nix
    # ../../modules/nixos/btrfs-sd-image.nix
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  fileSystems."/" = {
    fsType = lib.mkForce "btrfs";
    device = lib.mkForce "/dev/disk/by-label/disk-NIXOS_SD-root";
  };
  fileSystems."/boot".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;

  disko.devices.disk.NIXOS_SD = {
    type = "disk";
    device = "/dev/disk/by-label/NIXOS_SD";
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          start = "8M";
          size = "32M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            subvolumes = {
              "@root" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd:1" "noatime" ];
              };
              "@boot" = {
                mountpoint = "/boot";
                mountOptions = [ "noatime" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd:1" "noatime" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd:1" "noatime" ];
              };
              "@var" = { };
              "@var/log" = {
                mountpoint = "/var/log";
                mountOptions = [ "compress=zstd:1" "noatime" ];
              };
              "@var/lib" = {
                mountpoint = "/var/lib";
                mountOptions = [ "compress=zstd:1" "noatime" ];
              };
            };
          };
        };
      };
    };
  };

}

