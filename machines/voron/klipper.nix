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

  # systemd udev rule to restart Klipper
  systemd.udevRules = ''
    ACTION=="add", SUBSYSTEM=="tty", KERNEL=="ttyACM*", TAG+="systemd", ENV{SYSTEMD_WANTS}="klipper.service"
  '';

}
