{ config, ... }:
let
  rootDir = "/var/lib/octoprint";
  restartPath = "${rootDir}/restart";
in {
  nixpkgs.overlays = [
    (final: prev: {
      inherit (final.unstable) octoprint;
      ffmpeg = prev.ffmpeg.override { ffmpegVariant = "headless"; };
    })
  ];

  # 3d printer
  services.octoprint = {
    enable = true;
    openFirewall = true;
    stateDir = "${rootDir}/live";

    extraConfig = {
      server = {
        commands = { serverRestartCommand = "touch ${restartPath}"; };
      };
    };
  };

  # give permission to move stateDir to stateDir.bkp when restoring backups
  systemd.tmpfiles.rules = [
    "d '${rootDir}' - ${config.services.octoprint.user} ${config.services.octoprint.group} - -"
  ];

  systemd.paths.octoprint-watcher = {
    wantedBy = [ "multi-user.target" ];
    unitConfig = {
      User = config.services.octoprint.user;
      Group = config.services.octoprint.group;
    };
    pathConfig = {
      PathChanged = [ restartPath ];
      Unit = "octoprint-restarter.service";
    };
  };

  systemd.services.octoprint-restarter = {
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 5;
    };
    script = "systemctl restart octoprint.service";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
