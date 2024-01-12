{ inputs, ... }: {
  imports = [ inputs.disko.nixosModules.disko ];

  disko = {
    devices = {
      disk = {
        NIXOS_SD = {
          type = "disk";
          device = "/dev/disk/by-label/NIXOS_SD";
          content = {
            type = "gpt";
            partitions = {
              root = {
                start = "16M";
                size = "100%";
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "@root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@boot" = {
                      mountpoint = "/boot";
                      mountOptions = [ "noatime" ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@var" = { };
                    "@var/log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                    "@var/lib" = {
                      mountpoint = "/var/lib";
                      mountOptions = [ "compress=zstd:1" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}

