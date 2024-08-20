# TODO: upstream https://github.com/nix-community/home-manager/issues/2765
{ config, lib, ... }:
let
  cfg = config.programs.git.maintenance;
  gitCommand =
    schedule:
    let
      git = config.programs.git.package;
    in
    [
      "${git}/libexec/git-core/git"
      "--exec-path=${git}/libexec/git-core/"
      "for-each-repo"
      "--config=maintenance.repo"
      "maintenance"
      "run"
      "--schedule=${schedule}"
    ];
in
{
  options.programs.git.maintenance = {
    enable = lib.mkEnableOption {
      default = false;
      description = "Enable periodic git maintenance. See https://git-scm.com/docs/git-maintenance";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      services =
        let
          serviceCommand =
            { name, command }:
            {
              Unit = {
                Wants = "${name}.timer";
              };

              Service = {
                Type = "oneshot";
                ExecStart = command;
              };

              Install = {
                WantedBy = [ "multi-user.target" ];
              };
            };

          serviceGit =
            { schedule }:
            serviceCommand {
              name = "git-${schedule}";
              command = lib.concatStringsSep " " (gitCommand schedule);
            };
        in
        {
          git-hourly = serviceGit { schedule = "hourly"; };
          git-daily = serviceGit { schedule = "daily"; };
          git-weekly = serviceGit { schedule = "weekly"; };
        };

      timers =
        let
          timer =
            { name, onCalendar }:
            {
              Unit = {
                Requires = "${name}.service";
              };

              Timer = {
                OnCalendar = onCalendar;
                AccuracySec = "12h";
                Persistent = true;
              };

              Install = {
                WantedBy = [ "timers.target" ];
              };
            };
        in
        {
          "git.hourly" = timer {
            name = "git-hourly";
            onCalendar = "hourly";
          };

          "git.daily" = timer {
            name = "git-daily";
            onCalendar = "hourly";
          };

          "git.weekly" = timer {
            name = "git-weekly";
            onCalendar = "weekly";
          };
        };
    };

    launchd.agents =
      let
        agent =
          { schedule, startCalendarInterval }:
          {
            enable = true;
            config = {
              ProgramArguments = gitCommand schedule;
              StartCalendarInterval = startCalendarInterval;
            };
          };
      in
      {
        "git.hourly" = agent {
          schedule = "hourly";
          startCalendarInterval = [ { Minute = 0; } ];
        };

        "git.daily" = agent {
          schedule = "daily";
          startCalendarInterval = [
            {
              Minute = 0;
              Hour = 12;
            }
          ];
        };

        "git.weekly" = agent {
          schedule = "weekly";
          startCalendarInterval = [
            {
              Minute = 0;
              Hour = 12;
              Weekday = 1;
            }
          ];
        };
      };
  };
}
