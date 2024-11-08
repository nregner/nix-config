{
  appimageTools,
  sources,
}:
let
  inherit (sources.orca-slicer-x86_64-linux) pname version src;
  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraPkgs = pkgs: [ pkgs.webkitgtk ];
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/OrcaSlicer.desktop $out/share/applications/OrcaSlicer.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/192x192/apps/OrcaSlicer.png \
      $out/share/icons/hicolor/192x192/apps/OrcaSlicer.png
    substituteInPlace $out/share/applications/OrcaSlicer.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=env WEBKIT_DISABLE_DMABUF_RENDERER=1 ${pname}'
  '';
  passthru = {
    inherit appimageContents;
  };
  meta = {
    platforms = [ "x86_64-linux" ];
  };
}
