{ pkgs, fetchFromGitHub, armTrustedFirmwareAllwinnerH616, ... }@args:

#{ #patches=[]; }
pkgs.buildUBoot {
  version = "v2021.07";
  extraMeta.platforms = [ "aarch64-linux" ];

  # TODO: Flake input?
  src = fetchFromGitHub {
    owner = "orangepi-xunlong";
    repo = "u-boot-orangepi";
    rev = "0b91e222a025640182ea986f3c8e8db98cdc962a"; # v2021.10-sunxi
    sha256 = "sha256-sNsLKzsuLUiH9qcmEgJ5wzrGn0KMSGRHMJchk22r2ys=";
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
