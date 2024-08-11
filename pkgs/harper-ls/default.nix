{ sources, rustPlatform }:
let
  inherit (sources.harper-ls) pname version src;
in
rustPlatform.buildRustPackage {
  inherit pname version src;
  cargoLock.lockFile = "${src}/Cargo.lock";
}
