{ inputs, buildNpmPackage }:
buildNpmPackage {
  pname = "mainsail";
  version = "develop";
  src = inputs.mainsail;

  npmDepsHash = "sha256-W1hVA5GWYAwMDf8LRf64Le6JNKlspRYQL5fM54auWdM=";

  CYPRESS_INSTALL_BINARY = "0";

  buildPhase = ''
    npx vite build
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mainsail
    cp -r dist/* $out/share/mainsail

    runHook postInstall
  '';
}
