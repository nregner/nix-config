{ config, pkgs, ... }: {
  services.gitea = {
    enable = true;
    lfs = { enable = true; };
  };

  sops.secrets.gitea-github-mirror = { };

  systemd.timers.gitea-github-mirror = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    wantedBy = [ "timers.target" ];

    timerConfig = { OnCalendar = "daily"; };
  };

  systemd.services.gitea-github-mirror = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];

    serviceConfig = {
      EnvironmentFile = config.sops.secrets.gitea-github-mirror.path;
    };

    script = ''
      ${pkgs.gitea-github-mirror}/bin/gitea-github-mirror
    '';
  };

  services.backups.gitea = {
    paths = [ config.services.gitea.stateDir ];
    restic = { s3 = { }; };
  };
}
