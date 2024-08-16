{ self, lib, ... }:
{
  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = false;
    };
    openFirewall = true;
  };

  programs.ssh.knownHosts = self.globals.ssh.knownHosts;

  programs.ssh.extraConfig = ''
    Host enceladus-linux-vm
      User nregner
      HostName localhost
      ProxyJump enceladus
      Port 31022
  '';
}
