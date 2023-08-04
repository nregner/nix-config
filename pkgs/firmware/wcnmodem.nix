{ lib, stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation rec {
  pname = "wcnmodem-firmware";
  version = "1.0";

  # pulled from OrangePi OS image
  # TODO: Source from here instead: https://github.com/orangepi-xunlong/firmware
  src = [ ./wcnmodem.bin ./wifi_2355b001_1ant.ini ];
  unpackPhase = "true";
  dontFixup = true; # binaries must not be stripped or patchelfed

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/firmware/
    for s in $src; do
      cp $s $out/lib/firmware/''${s/*-/}
    done
    runHook postInstall
  '';

  # WIFI drivers are jank and have their own loading mechanism that doesn't support compression...
  passthru = { compressFirmware = false; };
}
