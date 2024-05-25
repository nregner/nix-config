{
  src,
  linuxManualConfig,
  ubootTools,
  ...
}:
(linuxManualConfig {
  version = "5.10.160-rockchip-rk3588";
  modDirVersion = "5.10.160";

  inherit src;

  configfile = ./orangepi5_config;

  extraMeta.branch = "5.10";

  # nix eval .\#nixosConfigurations.voron.config.system.build.kernel.config > machines/voron/kernel/config.nix
  # allowImportFromDerivation = true;
  config = import ./config.nix;
}).overrideAttrs
  (old: {
    name = "k"; # dodge uboot length limits
    nativeBuildInputs = old.nativeBuildInputs ++ [ ubootTools ];
  })
