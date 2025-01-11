{
  self,
  lib,
  ...
}:
{
  users.users.factorio = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = builtins.attrValues self.globals.ssh.userKeys.nregner;
    linger = true;
  };

  networking.firewall = {
    allowedUDPPorts = [ 34197 ];
  };

  users.users.craigslist = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = builtins.attrValues self.globals.ssh.userKeys.nregner;
    linger = true;
  };

  # https://discourse.nixos.org/t/nixos-rebuild-switch-is-failing-when-systemd-linger-is-enabled/31937/5
  systemd.user.services.nixos-activation.unitConfig.ConditionUser = lib.mkForce [
    "!craigslist"
    "!factorio"
  ];

  services.snapper = {
    snapshotInterval = "*:0/15";
    persistentTimer = true;
    # snapper -c home <...>
    # https://wiki.archlinux.org/title/Snapper
    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "nregner" ];
      TIMELINE_CLEANUP = true;
      TIMELINE_CREATE = true;
      TIMELINE_MIN_AGE = 1800;
      TIMELINE_LIMIT_DAILY = 7;
    };
  };

}
