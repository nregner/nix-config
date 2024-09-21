{ self, ... }:
{
  # https://wiki.nixos.org/wiki/Prometheus
  # https://nixos.org/manual/nixos/stable/#module-services-prometheus-exporters-configuration
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/default.nix
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "host_metrics";
        static_configs =
          builtins.map
            (node: {
              targets = [
                "${node}:${toString self.globals.services.prometheus.port}"
              ];
            })
            [
              "iapetus"
              "sagittarius"
              "sunlu-s8-0"
              "voron"
            ];
      }
    ];
  };
}
