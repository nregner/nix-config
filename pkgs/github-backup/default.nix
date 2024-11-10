# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md
{
  lib,
  mkShell,
  nvd,
  rust-analyzer,
  rustPlatform,
  rustfmt,
}:
let
  pkg = rustPlatform.buildRustPackage {
    pname = "hydra-auto-upgrade";
    version = "1.0.0";

    # src = lib.sources.sourceFilesBySuffices (lib.cleanSource ./.) [ ".nix" ];
    src = lib.cleanSource ./.;

    postPatch = ''
      ln -sf ${./Cargo.toml} Cargo.toml
      ln -sf ${./Cargo.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo.lock;

    runtimeInputs = [ nvd ];

    postConfigure = ''
      substituteInPlace src/main.rs \
        --replace-fail '"nvd"' '"${lib.getExe nvd}"'
    '';

    passthru.devShell = mkShell {
      RUST_SRC_PATH = "${rustPlatform.rustcSrc}/library";
      packages =
        pkg.nativeBuildInputs
        ++ pkg.buildInputs
        ++ [
          rust-analyzer
          rustfmt
        ];
    };
  };
in
pkg
