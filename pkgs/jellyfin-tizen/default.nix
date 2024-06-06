# https://github.com/jellyfin/jellyfin-tizen
{
  buildNpmPackage,
  jellyfin-web,
  lib,
  source,
  tizen,
}:
buildNpmPackage {
  inherit (source) pname version src;
  npmDepsHash = "sha256-WSAwzMRI6408MSsqhidGiCFVKOq1Gk4Hz7wPhdZcroU=";

  nativeBuildInputs = [ tizen ];

  # don't build on install
  npmFlags = [ "--ignore-scripts" ];

  preBuild = ''
    # gulp seems to have issues copying read-only directories/fiels (EACCES),
    # so make a rw copy
    find ${jellyfin-web}/share/jellyfin-web -type f -exec install -D {} -t .jellyfin-web \;
    export JELLYFIN_WEB_DIR="./.jellyfin-web"

    # reduce package size
    export DISCARD_UNUSED_FONTS=1
  '';

  postBuild = ''
    # TODO: is any of this really needed?
    substitute ${./profiles.xml} ./.profiles.xml \
      --replace-fail @CA@ ${./tizen-developer-ca.cer} \
      --replace-fail @KEY@ ${./jellyfin.p12} \
      --replace-fail @PASSWORD@ ${./password} \
      --replace-fail @CA_NEW@ ${./tizen-distributor-ca-new.cer} \
      --replace-fail @CA_KEY@ ${./tizen-distributor-signer-new.p12}
    tizen cli-config "profiles.path=$(pwd)/.profiles.xml" -g

    tizen build-web -e ".*" -e gulpfile.babel.js -e README.md -e "node_modules/*" -e "package*.json"
  '';

  installPhase = ''
    tizen package -t wgt -o $out -s Jellyfin -- .buildResult
  '';

  dontFixup = true;

  meta = with lib; {
    homepage = "https://github.com/jellyfin/jellyfin-tizen";
    description = "Jellyfin Samsung TV Client";
    license = licenses.gpl2;
    platforms = with platforms; linux ++ darwin;
  };
}
