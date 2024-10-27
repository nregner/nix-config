# https://github.com/ExpressLRS/ExpressLRS-Configurator/blob/master/.github/workflows/publish.yml
{
  electron,
  # electron_27,
  fetchYarnDeps,
  nodejs,
  python3,
  sources,
  stdenv,
  yarnBuildHook,
  yarnConfigHook,
  runCommand,
}:

let
  # electron = electron_27;

  inherit (sources.expresslrs-configurator) pname version src;

  # src = runCommand "expresslrs-configurator-src" { } ''
  #   mkdir $out
  #   cp -r ${sources.expresslrs-configurator.src}/* $out
  #   rm $out/{yarn.lock,package.json}
  #   cp ${./yarn.lock} $out/yarn.lock
  #   cp ${./package.json} $out/package.json
  # '';

  inherit (stdenv.hostPlatform) system;
  offlineCacheHash =
    {
      x86_64-linux = "sha256-UmJqI2UWf9s1HZVP4v50MgN+M06IW5/P7evAndDCfVU=";
      # aarch64-linux = "";
      # x86_64-darwin = "";
      aarch64-darwin = "";
    }
    .${system} or (throw "Unsupported system: ${system}");
  pkg = stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    offlineCache = fetchYarnDeps {
      yarnLock = ./yarn.lock;
      # yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = offlineCacheHash;
    };

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      nodejs
      (python3.withPackages (ps: with ps; [ setuptools ]))
      nodejs.pkgs.node-gyp-build
    ];

    env = {
      ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
      # npm_config_build_from_source = "true";
    };

    patchPhase = ''
      cp ${./package.json} .
      cp ${./yarn.lock} .
    '';

    buildPhase = ''
      yarn --offline package
    '';

    postBuild = ''
      # cp -r {electron.dist} electron-dist
      # chmod -R u+w electron-dist
      # yarn --offline run electron-builder --dir \
      #   -c.electronDist=electron-dist \
      #   -c.electronVersion={electron.version}
      yarn --offline run electron-builder --dir \
        -c.electronDist=${electron.dist} \
        -c.electronVersion=${electron.version}
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/expresslrs-configurator/
      cp -r release/linux-unpacked/{locales,resources}/* $out/share/expresslrs-configurator

      makeWrapper '${electron}/bin/electron' "$out/bin/expresslrs-configurator" \
        --add-flags "$out/share/expresslrs-configurator/app.asar" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto}}"
    '';

    dontFixup = true;

    meta = {
      homepage = "https://github.com/ExpressLRS/ExpressLRS-Configurator";
      description = "Cross platform configuration & build tool for the ExpressLRS radio link";
      # license = licenses.asl20;
      # maintainers = with maintainers; [ ];
      mainProgram = "expresslrs-configurator";
    };
  });
in
pkg
