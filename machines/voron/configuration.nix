{ inputs, config, lib, modulesPath, nixpkgs, pkgs, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    "${modulesPath}/profiles/minimal.nix"
    ../../common/global
    ./klipper.nix
    ./moonraker.nix
    ./mainsail.nix
  ];

  nixpkgs.hostPlatform = lib.mkForce "aarch64-linux";
  networking.hostName = "voron";

  users.users.root = {
    password = "root"; # ssh password auth disabled, so whatever :)
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor
      (pkgs.callPackage ./kernel { src = inputs.linux-rockchip; });

    supportedFilesystems = lib.mkForce [ "vfat" "fat32" "exfat" "ext4" ];

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
      name = "rockchip/rk3588s-orangepi-5.dtb";
      overlays = (let
        #        path = "${inputs.linux-rockchip}/arch/arm64/boot/dts/rockchip/overlay";
        path = ./kernel/dts;
        overlays = [
          "rk3588-pwm0-m1.dts"
          "rk3588-pwm13-m2.dts"
          "rk3588-pwm14-m1.dts"
          "rk3588-pwm15-m2.dts"
          "orangepi-5-sata.dts"
        ];
      in map (name: {
        inherit name;
        # dtsText = builtins.readFile "${path}/${name}";
        dtsFile = "${path}/${name}";
      }) overlays);
      /* lib.trivial.pipe (builtins.readDir path) [
           (lib.filterAttrs (name: type:
             type == "regular" && builtins.match
             ".*(rk3588-pwm|orangepi-5-sata|rk3588-i2c1-m2).*\\.dts" name != null))
           (lib.attrNames)
           (lib.naturalSort)
           (map (name: {
             inherit name;
             dtsFile = builtins.readFile "${path}/${name}";
           }))
         ]);
      */
    };
  };

  environment.systemPackages = with pkgs; [ wiring-op ];
  environment.etc = {
    "orangepi-release" = {
      text = ''
        BOARD=orangepi5
      '';
    };
  };

  #  passthru = rec {
  #    inherit (inputs) linux-rockchip;
  #    path = "${inputs.linux-rockchip}/arch/arm64/boot/dts/rockchip/overlay";
  #
  #    filtered = let
  #    in map (name: {
  #      name = name;
  #      dtsFile = builtins.readFile "${path}/${name}";
  #    }) (lib.naturalSort (lib.attrNames (lib.filterAttrs
  #      (name: type: type == "regular" && builtins.match ".*sata.*" name != null)
  #      (builtins.readDir path))));
  #
  #    filtered2 = let
  #      path = "${inputs.linux-rockchip}/arch/arm64/boot/dts/rockchip/overlay";
  #    in lib.trivial.pipe (builtins.readDir path) [
  #      (lib.filterAttrs (name: type:
  #        type == "regular" && builtins.match ".*sata.*" name != null))
  #      (lib.attrNames)
  #      (lib.naturalSort)
  #      (map (name: {
  #        name = name;
  #        dtsFile = builtins.readFile "${path}/${name}";
  #      }))
  #    ];
  #
  #  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
