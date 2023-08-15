{ pkgs, ... }: {
  services.klipper = {
    enable = true;
    package = pkgs.unstable.klipper;
    user = "klipper";
    group = "klipper";

    configFile = ./klipper.cfg;
    firmwares = {
      mcu = {
        enable = true;
        configFile = ./avr.cfg;
        serial =
          "/dev/serial/by-id/usb-Klipper_stm32f446xx_450016000450335331383520-if00";
      };
    };
  };

  # restart Klipper when printer is powerd on
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idProduct}=="614e", ATTRS{idVendor}=="1d50", ENV{SYSTEMD_WANTS}="klipper.service"
  '';

}
