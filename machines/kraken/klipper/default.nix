{ hostname, pkgs, ... }: {
  nixpkgs.overlays = [ (final: prev: { inherit (final.unstable) moonraker; }) ];

  # klipper
  services.klipper = {
    enable = true;
    user = "moonraker";
    group = "moonraker";
    configFile = ./printer-sunlu-s8-2020.cfg;
  };

  environment.systemPackages =
    [ pkgs.klipper-firmware-sunlu-s8.passthru.klipper-flash ];

  # FIXME
  # restart Klipper when printer is powerd on
  # https://github.com/Klipper3d/klipper/issues/835
  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idProduct}=="614e", ATTRS{idVendor}=="1d50", RUN+="${pkgs.bash} -c 'systemctl restart klipper.service'"
  '';

  # moonraker
  services.moonraker = {
    enable = true;
    allowSystemControl = true;

    settings = {
      authorization = {
        cors_domains = [ "*://*.nregner.net" "*://${hostname}" ];
        trusted_clients = [ "127.0.0.0/8" "::1/128" ];
      };
      history = { };
    };
  };

  # required for allowSystemControl
  security.polkit.enable = true;

  # mainsail
  services.mainsail = { enable = true; };
  services.nginx = { clientMaxBodySize = "1G"; };
}
