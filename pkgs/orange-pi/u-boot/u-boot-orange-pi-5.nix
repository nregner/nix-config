{ inputs, buildUBoot, # armTrustedFirmwareAllwinnerH616,
... }@args:
buildUBoot {
  version = "radxa-next";
  extraMeta.platforms = [ "aarch64-linux" ];

  src = inputs.u-boot-radxa-next;
  patches = [ ];

  defconfig = "orangepi5_defconfig";

  BL31 = "${armTrustedFirmwareAllwinnerH616}/bl31.bin";
  filesToInstall = [ "u-boot-sunxi-with-spl.bin" ];
}
