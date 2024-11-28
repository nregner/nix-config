{
  lib,
  sources,
  stdenv,
  xcbuildHook,
  xcodebuild,
  zsh,
}:
let
  inherit (sources.scroll-reverser) pname version src;
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    # xcbuildHook
    xcodebuild
    zsh
  ];

  xcbuildFlags = [
    "-configuration"
    "Release"
    "-project"
    "ScrollReverser.xcodeproj"
    # "-archivePath"
    # "$out"
    # "-scheme"
    # "libfoo Package (macOS only)"
  ];
  # __structuredAttrs = true;

  buildPhase = ''
    # exit 1
    export PROJECT_DIR=`pwd`
    echo $PROJECT_DIR
    export BUILT_PRODUCTS_DIR=$out
    xcodebuild -configuration Release
    mkdir -p "`pwd`/Products/Release/Scroll Reverser.app/Contents/Resources"
    mkdir -p "`pwd`/Products/Release/Scroll Reverser.app/Contents/MacOS"
    mkdir -p "`pwd`/Products/Release/Scroll Reverser.app/Contents"
    echo "`pwd`/Products/Release/Scroll Reverser.app/Contents/Resources"
    # scroll-reverser-v1.9> /private/tmp/nix-build-scroll-reverser-v1.9.drv-0/source/Products/Release/Scroll Reverser.app/Contents/Resources
    #           >     MkDir /private/tmp/nix-build-scroll-reverser-v1.9.drv-0/source/Products/Release/Scroll Reverser.app/Contents/MacOS

  '';

  postPatch = ''
    patchShebangs ./script/ ./BuildScripts/ ./ScrollReverser.xcodeproj
  '';

  # buildPhase = ''
  #   ./script/build
  # '';

  meta = {
    platforms = lib.platforms.darwin;
  };
}
