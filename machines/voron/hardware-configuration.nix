{
  inputs,
  sources,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.nixos-hardware.nixosModules.common-pc-ssd ];

  boot = {
    # kernelPackages = pkgs.linuxPackagesFor (
    #   pkgs.callPackage ./kernel { source = sources.linux-rockchip; }
    # );

    kernelPackages = pkgs.unstable.linuxPackages_6_1;

    supportedFilesystems = lib.mkForce [
      "vfat"
      "fat32"
      "exfat"
      "ext4"
    ];

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    initrd.includeDefaultModules = false;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  hardware = {
    enableRedistributableFirmware = true;
    deviceTree = {
      dtbSource = pkgs.callPackage ./device-tree.nix { source = sources.linux-rockchip; };
      name = "rockchip/rk3588s-orangepi-5.dtb";
      overlays = [
        {
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
        }
      ];
    };
  };

  networking.interfaces.end1.useDHCP = true;

  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
}
