{ config, inputs, lib, ... }: {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile =
    lib.mkDefault (../.. + "/${config.networking.hostName}/secrets.yaml");
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
}
