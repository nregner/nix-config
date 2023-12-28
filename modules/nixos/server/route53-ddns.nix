# derived from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/nixos/modules/services/networking/r53-ddns.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.route53-ddns;
in {
  options = {
    services.route53-ddns = {
      enable = mkEnableOption "route53-ddns";

      domain = mkOption {
        type = types.str;
        description = "Domain to update";
      };

      ipType = mkOption {
        type = types.enum [ "public" "lan" ];
        description = "IP address to use";
      };

      ttl = mkOption {
        type = types.int;
        default = 300;
        description = "DNS record TTL";
      };

      interval = mkOption {
        type = types.str;
        default = "*-*-* *:00/15:00";
        description = lib.mdDoc ''
          Systemd calendar expression when to check for ip changes.
          See {manpage}`systemd.time(7)`.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "route53-ddns";
        description = lib.mdDoc "User for the daemon";
      };

      group = mkOption {
        type = types.str;
        default = "route53-ddns";
        description = lib.mdDoc "Group for the daemon";
      };

      environmentFile = mkOption {
        type = types.str;
        description = mdDoc ''
          Path to a containing the HOSTED_ZONE_ID, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY
          in the format of an EnvironmentFile as described by systemd.exec(5)
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    users.users = optionalAttrs (cfg.user == "route53-ddns") {
      route53-ddns = {
        group = cfg.group;
        isSystemUser = true;
        # uid = config.ids.uids.route53-ddns;
      };
    };

    users.groups = optionalAttrs (cfg.group == "route53-ddns") {
      # route53-ddns.gid = config.ids.gids.route53-ddns;
      route53-ddns = { };
    };

    systemd.timers.route53-ddns = {
      description = "route53-ddns timer";

      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      wantedBy = [ "timers.target" ];

      timerConfig = { OnCalendar = cfg.interval; };
    };

    systemd.services.route53-ddns = {
      description = "route53-ddns service";

      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];

      serviceConfig.EnvironmentFile = cfg.environmentFile;

      script = ''
        ${pkgs.route53-ddns}/bin/route53-ddns \
          --hosted-zone-id $HOSTED_ZONE_ID \
          --domain ${cfg.domain} \
          --ip ${cfg.ipType} \
          --ttl ${toString cfg.ttl}
      '';
    };
  };
}
