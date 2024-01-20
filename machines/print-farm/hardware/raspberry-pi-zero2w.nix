{ modulesPath, pkgs, lib, ... }: {
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ./disko-image.nix
    ../disko.nix
    # "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # ./sd-image.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      qemu = prev.qemu.override {
        gtkSupport = false;
        pipewireSupport = false;
      };
    })
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  zramSwap.enable = true;

  # sdImage = {
  #   # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low on space.
  #   compressImage = true;
  #   imageName = "zero2.img";

  #   extraFirmwareConfig = {
  #     # Give up VRAM for more Free System Memory
  #     # - Disable camera which automatically reserves 128MB VRAM
  #     start_x = 0;
  #     # - Reduce allocation of VRAM to 16MB minimum for non-rotated (32MB for rotated)
  #     gpu_mem = 16;

  #     # Configure display to 800x600 so it fits on most screens
  #     # * See: https://elinux.org/RPi_Configuration
  #     hdmi_group = 2;
  #     hdmi_mode = 8;
  #   };
  # };

  # Keep this to make sure wifi works
  hardware.enableRedistributableFirmware = lib.mkForce false;
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  boot = {
    # TODO doesn't work
    # kernelPackages = pkgs.linuxKernel.packages.linux_rpi3;

    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # Avoids warning: mdadm: Neither MAILADDR nor PROGRAM has been set. This will cause the `mdmon` service to crash.
    # See: https://github.com/NixOS/nixpkgs/issues/254807
    swraid.enable = lib.mkForce false;
  };
}
