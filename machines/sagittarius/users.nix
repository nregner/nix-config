{ self, ... }:
{
  users.users.factorio = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = builtins.attrValues self.globals.ssh.userKeys.nregner;
  };

  networking.firewall = {
    allowedUDPPorts = [ 34197 ];
  };

  users.users.craigslist = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
    openssh.authorizedKeys.keys = builtins.attrValues self.globals.ssh.userKeys.nregner;
  };
}
