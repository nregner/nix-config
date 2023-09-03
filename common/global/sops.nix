{ config, inputs, lib, ... }:
let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops.defaultSopsFile = lib.mkDefault
    (../.. + "/machines/${config.networking.hostName}/secrets.yaml");
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = [ ];
}
