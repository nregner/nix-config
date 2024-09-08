{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.hydraAutoUpgrade;
in
{
  # derived from: https://github.com/Misterio77/nix-config/blob/main/modules/nixos/hydra-auto-upgrade.nix
  options = {
    system.hydraAutoUpgrade = {
      enable = lib.mkEnableOption "periodic hydra-based auto upgrade";
      operation = lib.mkOption {
        type = lib.types.enum [
          "switch"
          "boot"
        ];
        default = "boot";
      };
      dates = lib.mkOption {
        type = lib.types.str;
        default = "04:40";
        example = "daily";
      };

      instance = lib.mkOption {
        type = lib.types.str;
        default = "https://hydra.nregner.net";
      };
      project = lib.mkOption {
        type = lib.types.str;
        default = "nix-config";
      };
      jobset = lib.mkOption {
        type = lib.types.str;
        default = "master";
      };
      job = lib.mkOption {
        type = lib.types.str;
        default = ''nixosConfigurations.${config.networking.hostName}'';
      };

      oldFlakeRef = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = ''
          Current system's flake reference

          If non-null, the service will only upgrade if the new config is newer
          than this one's.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      script = pkgs.unstable.writeShellApplication {
        name = "hydra-auto-upgrade";
        runtimeInputs = with pkgs.unstable; [
          config.nix.package.out
          # config.programs.ssh.package
          coreutils
          curl
          # gitMinimal
          # gnutar
          # gzip
          jq
          nvd
        ];
        text = ''
          jobset="${cfg.jobset}"
          while [[ "$#" -gt 0 ]]; do
            case "$1" in
              -o|--operation)
                operation="$2"
                shift
                shift
                ;;
              -j|--jobset)
                jobset="$2"
                shift
                shift
                ;;
              *)
                echo "Unknown option $1"
                exit 1
                ;;
            esac
          done

          buildUrl="${cfg.instance}/job/${cfg.project}/$jobset/${cfg.job}/latest";
          profile="/nix/var/nix/profiles/system"
          path="$(curl -sLH 'accept: application/json' "$buildUrl" | jq -r '.buildoutputs.out.path')"

          if [ "$(readlink -f "$profile")" = "$path" ]; then
            echo "Already up to date" >&2
            exit 0
          fi

          echo "Building $path" >&2
          nix build --no-link "$path"

          echo "Comparing changes" >&2
          nvd --color=always diff "$profile" "$path"

          echo "Activating configuration" >&2
          "$path/bin/switch-to-configuration" "$operation"

          echo "Setting profile" >&2
          nix build --no-link --profile "$profile" "$path"
        '';
      };
    in
    {
      assertions = [
        {
          assertion = cfg.enable -> !config.system.autoUpgrade.enable;
          message = ''
            hydraAutoUpgrade and autoUpgrade are mutually exclusive.
          '';
        }
      ];

      environment.systemPackages = [ script ];

      systemd.services.nixos-upgrade = {
        description = "NixOS Upgrade";
        restartIfChanged = false;
        unitConfig.X-StopOnRemoval = false;
        serviceConfig.Type = "oneshot";

        script = ''
          ${lib.getExe script} --operation ${cfg.operation}
        '';

        startAt = cfg.dates;
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
      };
    }
  );
}
