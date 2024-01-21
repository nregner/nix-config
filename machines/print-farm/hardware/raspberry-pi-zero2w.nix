{ modulesPath, pkgs, lib, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    "${modulesPath}/profiles/minimal.nix"
    ./disko-image.nix
    ../disko.nix
    # "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # ./sd-image.nix
  ];

  # TODO: move to disko-image.nix
  nixpkgs.overlays = [
    (final: prev: {
      qemu = prev.qemu.override {
        gtkSupport = false;
        pipewireSupport = false;
      };
    })
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # Keep this to make sure wifi works
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  # limited memory: enable swap
  zramSwap.enable = true;

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    # swraid.enable = lib.mkForce false;
  };

  imports = [
    # ../../modules/nixos/disko-sd-image.nix
    # ../../modules/nixos/btrfs-sd-image.nix
    # "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  # fileSystems."/" = {
  #   fsType = lib.mkForce "btrfs";
  #   device = lib.mkForce "/dev/disk/by-label/disk-NIXOS_SD-root";
  # };
  # fileSystems."/boot".neededForBoot = true;
  # fileSystems."/var/log".neededForBoot = true;

  disko.devices.disk.NIXOS_SD = {
    type = "disk";
    device = "/dev/disk/by-label/NIXOS_SD";
    imageSize = "1G";
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

  boot.loader = {
    grub.enable = false;
    raspberryPi = {
      enable = true;
      version = 3;
      firmwareConfig = ''
        # Give up VRAM for more Free System Memory
        # - Disable camera which automatically reserves 128MB VRAM
        start_x=0;
        # - Reduce allocation of VRAM to 16MB minimum for non-rotated (32MB for rotated)
        gpu_mem=16;

        # Configure display to 800x600 so it fits on most screens
        # * See: https://elinux.org/RPi_Configuration
        hdmi_group=2;
        hdmi_mode=8;
      '';
    };
  };
}
