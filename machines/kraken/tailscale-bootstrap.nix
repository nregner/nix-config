{ config, lib, pkgs, ... }:
let cfg = config.services.tailscale-bootstrap;
in {
  # source: https://tailscale.com/blog/nixos-minecraft/
  options.services.tailscale-bootstrap = {
    enable = lib.mkEnableOption (lib.mdDoc "Automatic Tailscale registration");
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.tailscale-auth-key.sopsFile = ./secrets.yaml;

    systemd.services.tailscale-bootstrap = {
      description = "Automatic Tailscale registration";

      after = [ "network-pre.target" "tailscale.service" ];
      wants = [ "network-pre.target" "tailscale.service" ];

      serviceConfig.Type = "oneshot";

      script = with pkgs; ''
        # wait for tailscaled to settle
        sleep 2

        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up --ssh -authkey="$(<${config.sops.secrets.tailscale-auth-key.path})"
      '';
    };
  };
}
