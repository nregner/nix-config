{
  appimageTools,
  fetchurl,
  lib,
  cura,
}:
let
  pname = "cura";
  version = "5.8.1";
  src = fetchurl {
    url = "https://github.com/Ultimaker/Cura/releases/download/${version}/UltiMaker-Cura-${version}-linux-X64.AppImage";
    hash = "sha256-VLd+V00LhRZYplZbKkEp4DXsqAhA9WLQhF933QAZRX0=";
  };
  appimageContents = appimageTools.extract { inherit pname version src; };
in
lib.warnIf (lib.versionOlder version cura.version) "cura is outdated. latest: ${cura.version}" (
  appimageTools.wrapType2 {
    inherit pname version src;
    extraPkgs = pkgs: [ pkgs.webkitgtk ];
    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/com.ultimaker.cura.desktop $out/share/applications/com.ultimaker.cura.desktop
      mkdir -p $out/share
      cp -r ${appimageContents}/usr/share/icons $out/share
      substituteInPlace $out/share/applications/com.ultimaker.cura.desktop \
        --replace-fail 'Exec=UltiMaker-Cura' 'Exec=env QT_QPA_PLATFORM=xcb ${pname}'
    '';
    passthru = {
      inherit appimageContents;
    };
  }
)
