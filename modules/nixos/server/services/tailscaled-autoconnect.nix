{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.tailscaled-autoconnect;
in
{
  # source: https://tailscale.com/blog/nixos-minecraft/
  options.services.tailscaled-autoconnect = {
    enable = lib.mkEnableOption (lib.mdDoc "Auto-connect to Tailscale");
    secretPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable (
    let
      secretPath =
        if (cfg.secretPath != null) then cfg.secretPath else config.sops.secrets.tailscale-auth-key.path;
    in
    {
      services.tailscale.enable = true;

      systemd.services.tailscaled-autoconnect = {
        description = "Auto-connect to Tailscale";

        wantedBy = [ "multi-user.target" ];
        requires = [ "network-online.target" ];
        after = [ "tailscale.service" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "5s";
          RestartSteps = 10;
          RestartMaxDelaySec = "5m";
        };

        script =
          let
            pkg = pkgs.writeShellApplication {
              name = "tailscaled-autoconnect";
              runtimeInputs = [
                config.services.tailscale.package
                pkgs.jq
              ];
              text = ''
                # let tailscaled settle
                sleep 2

                health="$(tailscale status -json | jq '.Health')"
                if [ "$health" = "null" ]; then
                echo "Already connected"
                exit 0
                fi

                echo "Authenticating... ($health)"
                tailscale up --reset --ssh --auth-key="file:${secretPath}"
              '';
            };
          in
          "${pkg}/bin/${pkg.name}";
      };

      services.networkd-dispatcher = {
        enable = true;
        rules."restart-tailscaled-autoconnect" = {
          onState = [ "routable" ];
          script = ''
            #!${pkgs.runtimeShell}
            systemctl restart tailscaled-autoconnect
          '';
        };
      };
    }
  );
}
