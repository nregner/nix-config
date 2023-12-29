{ inputs, lib, pkgs, ... }: {
  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";
    configFile = ./printer.cfg;
    firmwares = {
      mcu = {
        enable = true;
        configFile = ./firmware.cfg;
        serial =
          "/dev/serial/by-id/usb-Klipper_stm32f446xx_450016000450335331383520-if00";
      };
    };
  };

  # restart Klipper when printer is powerd on
  # https://github.com/Klipper3d/klipper/issues/835
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idProduct}=="614e", ATTRS{idVendor}=="1d50", RUN+="${pkgs.bash} -c 'systemctl restart klipper.service'"
  '';

  # use bleeding edge
  disabledModules = [ "services/misc/klipper.nix" ];
  imports =
    [ "${inputs.nixpkgs-unstable}/nixos/modules/services/misc/klipper.nix" ];

  nixpkgs.overlays = [ (final: prev: { inherit (final.unstable) klipper; }) ];
}
