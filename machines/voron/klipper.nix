{
  services.klipper = {
    user = "klipper";
    group = "klipper";
    enable = true;
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
}
