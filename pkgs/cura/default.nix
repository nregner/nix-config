{
  appimageTools,
  sources,
}:
let
  inherit (sources.cura-x86_64-linux) pname version src;
  appimageContents = appimageTools.extract { inherit pname version src; };
in
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
  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
