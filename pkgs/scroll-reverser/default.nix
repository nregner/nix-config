{
  lib,
  stdenvNoCC,
  sources,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.scroll-reverser) pname version src;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [ unzip ];

  sourceRoot = "Scroll Reverser.app";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
    cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

    runHook postInstall
  '';
})
