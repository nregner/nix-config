# https://github.com/NixOS/nixpkgs/pull/337022/files
{
  alsaLib,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  cups,
  dbus,
  electron,
  fetchzip,
  fontconfig,
  freetype,
  gcc,
  gtk3,
  lib,
  libdrm,
  libgcc,
  libglvnd,
  libpulseaudio,
  libstdcxx5,
  libxc,
  libxkbcommon,
  makeWrapper,
  mesa,
  musl,
  nspr,
  nss,
  pango,
  stdenv,
  wayland,
  wayland-protocols,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "expresslrs-configurator";
  version = "1.7.6";

  src = fetchzip {
    url = "https://github.com/ExpressLRS/ExpressLRS-Configurator/releases/download/v${version}/expresslrs-configurator-${version}.zip";
    stripRoot = false;
    sha256 = "sha256-EctYsCnEUmxPJnFPXVeNS84W5fZe/KwdO1Jeq7XD8is=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    gcc
    libgcc
    libstdcxx5
    musl
    libxc
    libxkbcommon
    alsaLib
    at-spi2-core
    gcc
    nss
    nspr
    cups
    libdrm
    gtk3
    pango
    cairo
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXrandr
    mesa
    libglvnd
    dbus
    libpulseaudio
    freetype
    fontconfig
    wayland
    wayland-protocols
  ];

  installPhase = ''
     mkdir -p $out/bin $out/share/expresslrs-configurator/
     cp -r $src/{locales,resources}/* $out/share/expresslrs-configurator

    makeWrapper '${electron}/bin/electron' "$out/bin/expresslrs-configurator" \
     --add-flags "$out/share/expresslrs-configurator/app.asar" \
     --add-flags "--enable-logging --log-file=/tmp/electron-log.txt" \
     --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
  '';

  meta = with lib; {
    description = "ExpressLRS Configurator is a cross-platform build & configuration tool for the ExpressLRS - open source RC link for RC applications.";
    homepage = "https://github.com/ExpressLRS/ExpressLRS-Configurator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ asamonik ];
  };
}
