# https://github.com/Hammerspoon/hammerspoon/tags
# https://github.com/NixOS/nixpkgs/pull/292296/files#diff-26375f4272499181f94d00c4f7cebcf92d12c67bc97f1b220ccf28ea79aed805
{
  lib,
  stdenvNoCC,
  sources,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (sources.hammerspoon) pname version src;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  nativeBuildInputs = [ unzip ];

  sourceRoot = "Hammerspoon.app";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
    cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool for powerful automation of macOS";
    longDescription = ''
      Hammerspoon is just a bridge between the operating system and a Lua scripting engine.
      What gives Hammerspoon its power is a set of extensions that expose specific pieces of system functionality, to the user.
    '';
    homepage = "http://www.hammerspoon.org";
    changelog = "http://www.hammerspoon.org/releasenotes/${finalAttrs.version}.html";
    license = with licenses; [ mit ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ afh ];
    platforms = lib.platforms.darwin;
  };
})
