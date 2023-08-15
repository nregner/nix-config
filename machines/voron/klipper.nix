{ pkgs, ... }: {
  nixpkgs.overlays = [ (final: prev: { inherit (final.unstable) klipper; }) ];

  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";
    configFile = ./klipper.cfg;
  };

  # restart Klipper when printer is powerd on
  # https://github.com/Klipper3d/klipper/issues/835
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idProduct}=="614e", ATTRS{idVendor}=="1d50", RUN+="${pkgs.bash} -c 'systemctl restart klipper.service'"
  '';
}
