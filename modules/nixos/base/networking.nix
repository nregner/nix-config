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
      HostName localhost
      ProxyJump nregner@enceladus
      Port 31022
  '';
}
