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

  # sudo ssh -v builder@enceladus-linux-vm
  # sudo ssh -J nregner@enceladus builder@localhost -p 31022 -i /etc/ssh/ssh_host_ed25519_key
  programs.ssh.extraConfig = ''
    # https://unix.stackexchange.com/questions/542618/ssh-proxyjump-with-key-on-jump-host
    Host enceladus-linux-vm
      HostName enceladus
      User root
      IdentityFile /etc/ssh/ssh_host_ed25519_key
      RemoteCommand ssh linux-builder
      RequestTTY yes
  '';
}
