{ inputs, config, lib, modulesPath, nixpkgs, pkgs, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    "${modulesPath}/profiles/minimal.nix"
    ../../common/global
  ];

  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
  networking.hostName = "voron";

  users.users.root = {
    password = "root"; # ssh password auth disabled, so whatever :)
  };

  # TODO: https://discourse.nixos.org/t/how-to-have-a-minimal-nixos/22652/3
  boot = {
    kernelPackages =
      inputs.orangepi-nix.packages.x86_64-linux.linux-orange-pi-6-5-rk3588;
    kernelParams = [ "boot.shell_on_fail" ];
    kernelModules = [
      "sprdwl_ng" # wifi driver
    ];
    supportedFilesystems = lib.mkForce [ "vfat" "ext4" ];
    consoleLogLevel = lib.mkDefault 7;

    initrd = { supportedFilesystems = lib.mkForce [ "vfat" "ext4" ]; };
    loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
  };

  hardware = {
    deviceTree = {
      name = "rockchip/rk3588s-orangepi-5.dtb";
      overlays = [{
        name = "orangepi5-sata-overlay";
        dtsText = ''
          // Orange Pi 5 Pcie M.2 to sata
          /dts-v1/;
          /plugin/;

          / {
            compatible = "rockchip,rk3588s-orangepi-5";

            fragment@0 {
              target = <&sata0>;

              __overlay__ {
                status = "okay";
              };
            };

            fragment@1 {
              target = <&pcie2x1l2>;

              __overlay__ {
                status = "disabled";
              };
            };
          };
        '';
      }];
    };
  };

  sdImage = {
    postBuildCommands = ''
      # Emplace bootloader to specific place in firmware file
      dd if=/dev/zero of=$img bs=1k count=1023 seek=1 status=noxfer \
          conv=notrunc # prevent truncation of image
      dd if=${pkgs.cross.u-boot-v2021_10-sunxi}/u-boot-sunxi-with-spl.bin of=$img bs=1k seek=8 conv=fsync \
          conv=notrunc # prevent truncation of image
    '';
    compressImage = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
