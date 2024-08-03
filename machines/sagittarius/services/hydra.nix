# sudo su hydra
# hydra-create-user nregner --full-name "Nathan Regner" --email-address nathanregner@gmail.com --password-prompt --role admin

{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.hydra = {
    enable = true;
    package = pkgs.unstable.hydra_unstable.overrideAttrs { doCheck = false; };
    hydraURL = "https://hydra.nregner.net";
    notificationSender = "hydra@nregner.net";
    useSubstitutes = true;
    port = 3001;
    buildMachinesFiles = [
      "/var/lib/hydra/machines"
      (pkgs.writeTextFile {
        name = "local-machine";
        text = "localhost ${pkgs.system} - 10 1 nixos-test,benchmark,big-parallel,kvm - -";
      })
    ];
    extraConfig = ''
      evaluator_workers = 10
      max_output_size = ${toString (4 * 1024 * 1024 * 1024)}
      always_supported_system_types = ${
        lib.concatStringsSep "," [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ]
      }
    '';
  };

  services.postgresql.identMap = ''
    hydra-users nregner hydra
  '';

  nix.extraOptions =
    let
      urls = [
        "https:"
        "github:"
      ];
    in
    ''
      extra-allowed-uris = ${lib.concatStringsSep " " urls}
    '';

  nginx.subdomain.hydra = {
    "/".proxyPass = "http://127.0.0.1:${toString config.services.hydra.port}/";
  };
}

# programs.ssh.extraConfig = ''
#   Host enceladus-linux-vm
#     ProxyJump nregner@enceladus
#     HostKeyAlias enceladus-linux-vm
#     Hostname localhost
#     Port 31022
#     User nregner
# '';

# TODO: private repo access
# sudo su hydra
# cd /var/lib/hydra
# $ cat .ssh/config
# Host github.com
#         StrictHostKeyChecking No
#         UserKnownHostsFile /dev/null
#         IdentityFile /var/lib/hydra/.ssh/id_ed25519
