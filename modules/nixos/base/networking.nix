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

  # ssh -J nregner@enceladus builder@localhost -p 31022
  programs.ssh.extraConfig = ''
    Host enceladus-linux-vm
      ProxyJump nregner@enceladus
      User builder
      HostName localhost
      Port 31022
  '';
}
