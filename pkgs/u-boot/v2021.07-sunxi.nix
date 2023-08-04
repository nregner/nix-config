{ pkgs, fetchFromGitHub, armTrustedFirmwareAllwinnerH616, ... }@args:

#{ #patches=[]; }
pkgs.buildUBoot {
  version = "v2021.07";
  extraMeta.platforms = [ "aarch64-linux" ];

  # TODO: Flake input?
  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "u-boot-orangepi";
    rev = "10ae13dc295d2644b8b1eb50c84d609d5c62c202"; # v2021.07-sunxi
    sha256 = "sha256-DUuRFrnP9yxX63md6+VpUBKrZRjzZE7oGCfyjeZtCQE=";
  };
  patches = [ ];

  defconfig = "orangepi_zero2_defconfig";
  #  extraConfig = ''
  #    CONFIG_ENV_EXT4_INTERFACE="mmc"
  #    CONFIG_ENV_EXT4_DEVICE_AND_PART="0:auto"
  #    CONFIG_ENV_EXT4_FILE="/boot/boot.env"
  #  '';

  BL31 = "${armTrustedFirmwareAllwinnerH616}/bl31.bin";
  filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
}
