{ inputs, lib, pkgs, ... }:
let
  vendor = "1d50";
  product = "614e";
  firmwareConfig = ./firmware.cfg;
  firmware = (pkgs.unstable.klipper-firmware.override {
    inherit firmwareConfig;
  }).overrideAttrs {
    installPhase = ''
      mkdir -p $out
      cp -r out/* $out/
      cp ./.config $out/config
      cp out/klipper.bin $out/ || true
      cp out/klipper.elf $out/ || true
    '';
  };
in {
  services.klipper = {
    package = pkgs.unstable.klipper;
    enable = true;
    user = "moonraker";
    group = "moonraker";
    configFile = ./printer.cfg;
  };

  disabledModules = [ "services/misc/klipper.nix" ];
  imports =
    [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/klipper.nix" ];

  # restart Klipper when printer is powerd on
  # https://github.com/Klipper3d/klipper/issues/835
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="${vendor}", ATTRS{idProduct}=="${product}", RUN+="${pkgs.bash} -c 'systemctl restart klipper.service'"
  '';

  # build and mount firmware.bin in a consistent location
  systemd.tmpfiles.rules =
    [ "L+ /var/lib/klipper/firmware - - - - ${firmware}" ];

  environment.systemPackages = [
    (pkgs.unstable.klipper-flash.override {
      klipper-firmware = firmware;
      flashDevice = "${vendor}:${product}";
      inherit firmwareConfig;
    })
  ];
}

