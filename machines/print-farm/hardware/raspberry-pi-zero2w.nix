{ inputs, modulesPath, pkgs, lib, ... }: {
  imports = [
    inputs.disko.nixosModules.disko
    # "${modulesPath}/profiles/minimal.nix"
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
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    # swraid.enable = lib.mkForce false;
  };

  disko.devices.disk.NIXOS_SD = {
    type = "disk";
    device = "/dev/disk/by-label/NIXOS_SD";
    imageSize = "3G";
    content = {
      type = "table";
      format = "msdos";
      partitions = [
        {
          name = "firmware";
          start = "8MiB";
          end = "40MiB";
          fs-type = "fat32";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
          };
        }
        {
          name = "root";
          end = "100%";
          bootable = true;
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ]; # Override existing partition
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
        }
      ];
    };
  };

  # TODO: Device tree config instead?
  disko.sdImage.postInstallScript = { pkgs }:
    let
      piPkgs = pkgs.pkgsCross.raspberryPi;
      configTxt = pkgs.writeText "config.txt" ''
        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1

        [pi0]
        kernel=u-boot-rpi0.bin

        [pi1]
        kernel=u-boot-rpi1.bin

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
    in pkgs.runCommand "firmware" { } ''
      firmware=$out/boot/firmware
      mkdir -p $firmware
      (cd ${piPkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $firmware)
      cp ${piPkgs.ubootRaspberryPiZero}/u-boot.bin $firmware/u-boot-rpi0.bin
      cp ${piPkgs.ubootRaspberryPi}/u-boot.bin $firmware/u-boot-rpi1.bin
      cp ${configTxt} $firmware/config.txt
    '';

}
