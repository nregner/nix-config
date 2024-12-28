{
  sources,
  rustPlatform,
  ...
}:
let
  source = sources.allfollow;
in
rustPlatform.buildRustPackage rec {
  inherit (source) pname version src;
  cargoLock.lockFile = "${src}/Cargo.lock";
}
