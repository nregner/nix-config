# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md
{
  lib,
  mkShell,
  openssl,
  rustPlatform,
  ...
}:
let
  pkg = rustPlatform.buildRustPackage {
    pname = "perf2ff";
    version = "1.0.0";

    # src = lib.sources.sourceFilesBySuffices (lib.cleanSource ./.) [ ".nix" ];
    src = lib.cleanSource ./.;

    postPatch = ''
      ln -sf ${./Cargo.toml} Cargo.toml
      ln -sf ${./Cargo.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo.lock;

    passthru.devShell = mkShell {
      RUST_SRC_PATH = "${rustPlatform.rustcSrc}/library";
      packages = pkg.nativeBuildInputs ++ pkg.buildInputs ++ [ openssl ];
    };
  };
in
pkg
