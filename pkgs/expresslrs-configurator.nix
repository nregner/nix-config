# https://github.com/ExpressLRS/ExpressLRS-Configurator/blob/master/.github/workflows/publish.yml
{
  electron_27,
  fetchYarnDeps,
  nodejs,
  python3,
  sources,
  stdenv,
  yarnBuildHook,
  yarnConfigHook,
}:

let
  electron = electron_27;

  inherit (sources.expresslrs-configurator) pname version src;
  inherit (stdenv.hostPlatform) system;
  offlineCacheHash =
    {
      x86_64-linux = "sha256-XgKao1CJ/6trBmyKNgRCmh0/wXLhBU4mFGU3+apyf3A=";
      # aarch64-linux = "";
      # x86_64-darwin = "";
      aarch64-darwin = "";
    }
    .${system} or (throw "Unsupported system: ${system}");
  pkg = stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    offlineCache = fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
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
