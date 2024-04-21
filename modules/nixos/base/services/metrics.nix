{ config, pkgs, lib, ... }: {
  options.services.nregner.metrics = {
    enable = lib.mkEnableOption "Ship basic system-level metrics";
  };

  config = lib.mkIf config.services.nregner.metrics.enable {
    services.metricbeat = {
      enable = true;
      package = pkgs.unstable.metricbeat7;
      modules = {
        # https://www.elastic.co/guide/en/beats/metricbeat/7.17/metricbeat-module-system.html#_example_configuration_59
        system = {
          metricsets = [
            "cpu"
            "load"
            "memory"
            "network"
            "process"
            "process_summary"
            "uptime"
            "socket_summary"
            "core" # Per CPU core usage
            "diskio" # Disk IO
            "filesystem" # File system usage for each mountpoint
            "fsstat" # File system summary metrics
            "raid" # Raid
            "socket" # Sockets and connection info (linux only)
            # "service" # systemd service information
          ];
          enabled = true;
          period = "10s";
          processes = [ ".*" ];
          cpu.metrics = [ "percentages" "normalized_percentages" ];
          core.metrics = [ "percentages" ];
        };
      };
      settings.output.elasticsearch.hosts = [ "http://sagittarius:9201" ];
    };
  };
}
