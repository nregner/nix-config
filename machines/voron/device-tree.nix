{
  bison,
  flex,
  pkg-config,
  source,
  stdenv,
  unzip,
  ...
}:
stdenv.mkDerivation {
  inherit (source) src version;
  pname = "orangepi5-dtbs";

  nativeBuildInputs = [
    bison
    flex
    pkg-config
    unzip
  ];

  enableParallelBuilding = true;

  makeFlags = [
    "defconfig"
    # TODO: just compile what's needed
    "dtbs"
  ];

  installPhase = ''
    mkdir -p $out/rockchip
    cp arch/arm64/boot/dts/rockchip/rk3588s-orangepi-5.dtb $out/rockchip
  '';
}
